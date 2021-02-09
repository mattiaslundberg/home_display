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

    title =
      Tesla.get("https://api.krisinformation.se/v1/feed?format=json")
      |> handle_response()
      |> Map.get("Title", "")

    Main.update_graph({:kris, "#{title}"})
    {:noreply, state}
  end

  def handle_response({:ok, %{body: body}}) do
    entries_to_consider =
      body
      |> Jason.decode!()
      |> Map.get("Entries", [])
      |> Enum.filter(&filter_entries/1)

    if length(entries_to_consider) == 0 do
      %{}
    else
      List.first(entries_to_consider)
    end
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
