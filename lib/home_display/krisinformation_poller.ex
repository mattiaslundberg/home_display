defmodule HomeDisplay.KrisinformationPoller do
  use GenServer
  require Logger

  @wait_between 360_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl GenServer
  def init(_) do
    Process.send_after(self(), :check, 1000)

    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:check, state) do
    Process.send_after(self(), :check, @wait_between)

    latest_event =
      Tesla.get("https://api.krisinformation.se/v1/feed?format=json")
      |> handle_response()

    title = Map.get(latest_event, "Title", "")
    HomeDisplay.Scene.Main.update_krisinformation("#{title}")
    {:noreply, state}
  end

  def handle_response({:ok, %{body: body}}) do
    body
    |> Jason.decode!()
    |> Map.get("Entries", [])
    |> List.first()
  end

  def handle_response(_), do: %{}
end
