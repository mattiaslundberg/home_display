defmodule HomeDisplay.Web.HttpRouter do
  use Plug.Router
  alias HomeDisplay.Scene.Main

  plug(:match)
  plug(:dispatch)

  post "/temperature" do
    {:ok, body, conn} = conn |> read_body()

    body
    |> Jason.decode!()
    |> Enum.each(fn {sensor_id, temperature} ->
      Main.update_graph({:temp, sensor_id, temperature})
    end)

    send_resp(conn, 200, "ok")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
