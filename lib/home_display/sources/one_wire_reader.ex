defmodule HomeDisplay.Sources.OneWireReader do
  use GenServer
  require Logger

  alias HomeDisplay.Reporters.{InfluxConnection, TemperatureSeries}
  alias HomeDisplay.Scene.Main

  @wait_between 360_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl GenServer
  def init(_) do
    Process.send_after(self(), :check, 10_000)

    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:check, state) do
    Process.send_after(self(), :check, @wait_between)

    OneWire.read_sensors()
    |> Enum.each(&handle_reading/1)

    {:noreply, state}
  end

  defp handle_reading({sensor_id, temperature}) do
    InfluxConnection.write(%TemperatureSeries{
      fields: %TemperatureSeries.Fields{value: temperature},
      tags: %TemperatureSeries.Tags{location: "home-display", sensor_id: sensor_id}
    })

    Main.update_graph({:temp, sensor_id, temperature})
  end
end