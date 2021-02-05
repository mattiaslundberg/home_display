defmodule HomeDisplay.Sources.DatePoller do
  use GenServer
  require Logger

  @wait_between 3_600_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def check_now(pid) do
    send(pid, :check)
  end

  @impl GenServer
  def init(_) do
    Process.send_after(self(), :check, 1000)

    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:check, state) do
    Process.send_after(self(), :check, @wait_between)
    main = Application.get_env(:home_display, :main_scene)

    content = Timex.format!(Timex.now(), "{D}/{M}")
    main.update_graph({:today, content})

    content = Timex.format!(Timex.now(), "{WDshort}")
    main.update_graph({:day, content})
    {:noreply, state}
  end
end
