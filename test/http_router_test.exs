defmodule HomeDisplay.HttpRouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias HomeDisplay.Web.HttpRouter
  import Mox

  @opts HomeDisplay.Web.HttpRouter.init([])

  test "post temperature" do
    parent = self()

    HomeDisplay.Scene.MainMock
    |> expect(:update_graph, 1, fn
      {:temp, "smhi", 32} ->
        send(parent, :handled)
        :ok
    end)

    conn =
      conn(:post, "/temperature", "{\"smhi\": 32}")
      |> put_req_header("content-type", "application/json")
      |> HttpRouter.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert_receive :handled
  end

  test "404" do
    conn =
      conn(:get, "/nonexistsing")
      |> HttpRouter.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
