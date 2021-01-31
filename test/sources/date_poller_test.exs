defmodule HomeDisplay.Sources.DatePollerTest do
  use ExUnit.Case, async: true
  alias HomeDisplay.Sources.DatePoller

  import Mox

  setup :verify_on_exit!

  test "loads date" do
    {:ok, pid} = DatePoller.start_link(nil)
    parent = self()

    HomeDisplay.Scene.MainMock
    |> expect(:update_graph, 2, fn
      {:today, _} ->
        send(parent, :handle)
        :ok

      {:day, _} ->
        send(parent, :handle2)
        :ok
    end)

    allow(
      HomeDisplay.Scene.MainMock,
      self(),
      pid
    )

    DatePoller.check_now(pid)
    assert_receive :handle
    assert_receive :handle2
  end
end
