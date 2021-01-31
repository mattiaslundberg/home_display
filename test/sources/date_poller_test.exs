defmodule HomeDisplay.Sources.DatePollerTest do
  use ExUnit.Case, async: true
  alias HomeDisplay.Sources.DatePoller

  import Mox

  setup :verify_on_exit!

  test "loads date" do
    {:ok, pid} = DatePoller.start_link(nil)

    HomeDisplay.Scene.MainMock
    |> expect(:update_graph, 2, fn
      {:today, _} -> :ok
      {:day, _} -> :ok
    end)

    allow(
      HomeDisplay.Scene.MainMock,
      self(),
      pid
    )

    DatePoller.check_now(pid)
    Process.sleep(100)
  end
end
