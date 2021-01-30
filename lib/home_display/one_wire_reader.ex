defmodule HomeDisplay.OneWireReader do
  use GenServer
  require Logger

  alias HomeDisplay.{TemperatureSeries, InfluxConnection}

  @wait_between 360_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl GenServer
  def init(_) do
    Process.send_after(self(), :check, 10000)

    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:check, state) do
    Process.send_after(self(), :check, @wait_between)

    OneWire.read_sensors()
    |> Enum.map(&handle_reading/1)

    {:noreply, state}
  end

  defp handle_reading({sensor_id, temperature}) do
    InfluxConnection.write(%TemperatureSeries{
      fields: %TemperatureSeries.Fields{value: temperature},
      tags: %TemperatureSeries.Tags{location: "home-display", sensor_id: sensor_id}
    })

    HomeDisplay.Scene.Main.update_graph({:temp, sensor_id, temperature})
  end
end
