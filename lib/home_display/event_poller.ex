defmodule HomeDisplay.EventPoller do
  use GenServer
  require Logger

  # @wait_between 2000

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
    |> List.first()
  end

  defp get_and_parse(url) do
    case Tesla.get(url) do
      {:ok, %{body: body}} ->
        ExIcal.parse(body)

      _ ->
        nil
    end
  end

  @impl GenServer
  def handle_cast({:next_event, event}, state = %{last_event: last_event}) do
    if is_map(last_event) and event.uid == Map.get(last_event, :uid, "undefined") do
      {:noreply, state}
    else
      HomeDisplay.Scene.Main.update_event(event)

      {:noreply, %{state | last_event: event}}
    end
  end
end
