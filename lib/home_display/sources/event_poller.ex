defmodule HomeDisplay.Sources.EventPoller do
  use GenServer
  require Logger
  alias HomeDisplay.Scene.Main

  @wait_between 360_000

  def start_link(urls: calendar_urls) do
    GenServer.start_link(__MODULE__, calendar_urls)
  end

  @impl GenServer
  def init(calendar_urls) do
    Process.send_after(self(), :check, 3000)

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
    |> Enum.map(&get_and_parse/1)
    |> List.flatten()
    |> ExIcal.sort_by_date()
    |> List.first()
  end

  defp get_and_parse(url) do
    case Tesla.get(url) do
      {:ok, %{body: body}} ->
        body
        |> ExIcal.parse()
        |> Enum.filter(&filter_event/1)

      _ ->
        []
    end
  end

  @impl GenServer
  def handle_cast({:next_event, event = %{summary: summary}}, state) do
    Main.update_graph({:event, summary})
    Main.update_graph({:event_time, pretty_start(event)})

    {:noreply, %{state | last_event: event}}
  end

  def handle_cast(_, state) do
    Logger.info("Failed to update with event")
    {:noreply, state}
  end

  defp pretty_start(%{start: start}) do
    if Timex.equal?(start, Timex.beginning_of_day(start)) do
      start
      |> Timex.to_datetime("Europe/Stockholm")
      |> Timex.format!("{D}/{M}")
    else
      start
      |> Timex.to_datetime("Europe/Stockholm")
      |> Timex.format!("{D}/{M} {h24}:{m}")
    end
  end

  defp filter_event(event) do
    now = Timex.now()
    upcomming = Timex.diff(event.start, now) > 0
    next_week = Timex.diff(event.start, Timex.add(now, Timex.Duration.from_days(7))) < 0
    upcomming and next_week
  end
end
