defmodule HomeDisplay.Display do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  @impl GenServer
  def init(_) do
    {:ok, pid} =
      Inky.start_link(:phat, :red, %{
        hal_mod: Application.get_env(:inky, :hal_module, Inky.RpiHAL)
      })

    send(self(), :redraw)

    {:ok, %{inky_pid: pid, count: 20}}
  end

  @impl GenServer
  def handle_info(:redraw, %{inky_pid: pid, count: count} = state) do
    :ok =
      Inky.set_pixels(pid, fn x, y, _width, _height, _current ->
        if y == count do
          :black
        else
          :white
        end
      end)

    Process.send_after(self(), :redraw, 10000)

    {:noreply, %{state | count: count + 1}}
  end
end
