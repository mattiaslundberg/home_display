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
    Process.send_after(self(), :check, 1000)

    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:check, state) do
    Process.send_after(self(), :check, @wait_between)

    case OneWire.read_sensors() do
      [temperature] ->
        InfluxConnection.write(%TemperatureSeries{
          fields: %TemperatureSeries.Fields{value: temperature},
          tags: %TemperatureSeries.Tags{location: "home-display"}
        })

        HomeDisplay.Scene.Main.update_graph({:local_temp, "L #{temperature}"})

      _ ->
        Logger.error("Exactly one senor required...")
    end

    {:noreply, state}
  end
end
