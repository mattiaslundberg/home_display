defmodule HomeDisplay.EventPoller do
  use GenServer
  require Logger

  @wait_between 80_000

  def start_link(urls: calendar_urls) do
    GenServer.start_link(__MODULE__, calendar_urls)
  end

  @impl GenServer
  def init(calendar_urls) do
    send(self(), :check)

    {:ok, %{calendar_urls: calendar_urls, last_event: nil}}
  end

  @impl GenServer
  def handle_info(:check, state) do
    Process.send_after(self(), :check, @wait_between)

    next_event =
      state.calendar_urls
      |> get_next_event()

    GenServer.cast(self(), {:next_event, next_event})

    {:noreply, state}
  end

  def get_next_event(urls) do
    urls
    |> Task.async_stream(&get_and_parse/1)
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.reduce([], fn a, acc -> acc ++ a end)
    |> ExIcal.sort_by_date()
    |> List.first()
  end

  defp get_and_parse(url) do
    case Tesla.get(url) do
      {:ok, %{body: body}} ->
        body |> ExIcal.parse() |> Enum.filter(&filter_event/1)

      _ ->
        []
    end
  end

  @impl GenServer
  def handle_cast({:next_event, event}, state) do
    HomeDisplay.Scene.Main.update_event(event)

    {:noreply, %{state | last_event: event}}
  end

  defp filter_event(event) do
    now = Timex.now()
    upcomming = Timex.diff(event.start, now)
    next_week = Timex.diff(event.start, Timex.add(now, Timex.Duration.from_days(7)))
    upcomming > 0 and next_week < 0
  end
end
