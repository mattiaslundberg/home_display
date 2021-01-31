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
      _ -> :ok
    end)

    allow(
      HomeDisplay.Scene.MainMock,
      self(),
      pid
    )

    Process.sleep(2000)
    DatePoller.check_now(pid)
  end
end
