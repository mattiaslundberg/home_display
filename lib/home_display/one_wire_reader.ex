defmodule HomeDisplay.OneWireReader do
  use GenServer
  require Logger

  @wait_between 80_000

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
        HomeDisplay.Scene.Main.update_graph({:local_temp, "#{temperature}"})

      _ ->
        Logger.error("Exactly one senor required...")
    end

    {:noreply, state}
  end
end
