defmodule HomeDisplay.OneWireReaderTest do
  use ExUnit.Case, async: true
  alias HomeDisplay.Sources.OneWireReader

  import Mox

  setup :verify_on_exit!

  test "handle successful reading" do
    parent = self()

    HomeDisplay.Scene.MainMock
    |> expect(:update_graph, 1, fn
      {:temp, "smhi", 33.9} ->
        send(parent, :handled)
        :ok
    end)

    HomeDisplay.Reporters.InfluxConnectionMock
    |> expect(:write, 1, fn
      _ ->
        send(parent, :handled2)
        :ok
    end)

    OneWireReader.handle_reading({"smhi", 33.9})

    assert_receive :handled
    assert_receive :handled2
  end
end
