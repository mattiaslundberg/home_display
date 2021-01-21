defmodule HomeDisplay.WeatherPoller do
  use GenServer

  alias Nerves.Utils.HTTPClient

  @one_hour 3_600_000

  def start_link(location: location) do
    GenServer.start_link(__MODULE__, %{location: location})
  end

  @impl GenServer
  def init(%{location: location}) do
    {:ok, client_pid} = HTTPClient.start_link()

    send(self(), :check)

    {:ok, %{location: location, client_pid: client_pid, last_temp: ""}}
  end

  @impl GenServer
  def handle_info(:check, state = %{location: location, client_pid: client_pid}) do
    Process.send_after(self(), :check, @one_hour)

    new_value =
      HTTPClient.get(
        client_pid,
        "https://opendata-download-metobs.smhi.se/api/version/1.0/parameter/1/station/#{location}/period/latest-day/data.json"
      )
      |> handle_response()

    GenServer.cast(self(), {:new_temp, new_value})

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:new_temp, new_temp}, state = %{last_temp: last_temp}) do
    if new_temp != last_temp do
      HomeDisplay.Scene.Main.update_temp(new_temp)
      {:noreply, %{state | last_temp: new_temp}}
    else
      {:noreply, state}
    end
  end

  defp handle_response({:ok, raw_response}) do
    raw_response |> Jason.decode!() |> Map.get("value", []) |> latest_value()
  end

  defp handle_response(_), do: nil

  defp latest_value(values) do
    values
    |> Enum.sort(fn a, b -> Map.get(a, "date") > Map.get(b, "date") end)
    |> hd()
    |> Map.get("value")
  end
end
