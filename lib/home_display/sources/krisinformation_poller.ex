defmodule HomeDisplay.Sources.KrisinformationPoller do
  use GenServer
  require Logger
  alias HomeDisplay.Scene.Main

  @wait_between 3_600_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl GenServer
  def init(_) do
    Process.send_after(self(), :check, 3000)

    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:check, state) do
    Process.send_after(self(), :check, @wait_between)

    latest_event =
      Tesla.get("https://api.krisinformation.se/v1/feed?format=json")
      |> handle_response()

    title = Map.get(latest_event, "Title", "")
    Main.update_graph({:kris, "#{title}"})
    {:noreply, state}
  end

  def handle_response({:ok, %{body: body}}) do
    body
    |> Jason.decode!()
    |> Map.get("Entries", [])
    |> Enum.filter(&filter_entries/1)
    |> List.first()
  end

  def handle_response(_), do: %{}

  defp filter_entries(%{"CapArea" => areas}) do
    Enum.any?(areas, fn %{"CapAreaDesc" => area} ->
      relevant?(area)
    end)
  end

  defp relevant?(area) do
    cond do
      String.starts_with?(area, "Stockholm") -> true
      String.starts_with?(area, "Sverige") -> true
      true -> false
    end
  end
end
