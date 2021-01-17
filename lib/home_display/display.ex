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

    {:ok, %{inky_pid: pid, count: 1}}
  end

  @impl GenServer
  def handle_info(:redraw, %{inky_pid: pid, count: count} = state) do
    count = rem(count, 2)

    Inky.set_pixels(pid, fn x, y, _width, _height, _current ->
      x_odd = rem(x, 2) != 0
      y_odd = rem(y, 2) != 0

      case x_odd do
        true ->
          case y_odd do
            true -> if count == 1, do: :black, else: :accent
            false -> :accent
          end

        false ->
          case y_odd do
            true -> if count != 1, do: :black, else: :accent
            false -> :white
          end
      end
    end)

    Process.send_after(self(), :redraw, 1000)

    {:noreply, %{state | count: count + 1}}
  end
end
