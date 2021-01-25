defmodule HomeDisplay.DatePoller do
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
    HomeDisplay.Scene.Main.update_today(Timex.now())
    {:noreply, state}
  end
end
