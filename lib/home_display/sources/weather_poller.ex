defmodule HomeDisplay.Sources.WeatherPoller do
  use GenServer
  require Logger
  alias HomeDisplay.Scene.Main

  @wait_between 3_600_000

  def start_link(location: location) do
    GenServer.start_link(__MODULE__, %{location: location})
  end

  @impl GenServer
  def init(%{location: location}) do
    Process.send_after(self(), :check, 10_000)

    {:ok, %{location: location, last_temp: ""}}
  end

  @impl GenServer
  def handle_info(:check, state = %{location: location}) do
    Process.send_after(self(), :check, @wait_between)

    new_value =
      Tesla.get(
        "https://opendata-download-metobs.smhi.se/api/version/1.0/parameter/1/station/#{location}/period/latest-day/data.json"
      )
      |> handle_response()

    GenServer.cast(self(), {:new_temp, new_value})

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:new_temp, new_temp}, state)
      when is_binary(new_temp) do
    temp = String.to_float(new_temp)
    Main.update_graph({:temp, "smhi", temp})
    {:noreply, %{state | last_temp: new_temp}}
  end

  defp handle_response({:ok, %{body: body}}) do
    body |> Jason.decode!() |> Map.get("value", []) |> latest_value()
  end

  defp handle_response(_), do: nil

  defp latest_value(values) do
    values
    |> Enum.sort(fn a, b -> Map.get(a, "date") > Map.get(b, "date") end)
    |> List.first()
    |> Map.get("value")
  end
end
