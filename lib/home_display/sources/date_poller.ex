defmodule HomeDisplay.Sources.DatePoller do
  use GenServer
  require Logger
  alias HomeDisplay.Scene.Main

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

    content = Timex.format!(Timex.now(), "{D}/{M}")
    Main.update_graph({:today, content})

    content = Timex.format!(Timex.now(), "{WDshort}")
    Main.update_graph({:day, content})
    {:noreply, state}
  end
end