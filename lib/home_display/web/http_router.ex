defmodule HomeDisplay.Web.HttpRouter do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  post "/temperature" do
    {:ok, body, conn} = conn |> read_body()
    main = Application.get_env(:home_display, :main_scene)

    body
    |> Jason.decode!()
    |> Enum.each(fn {sensor_id, temperature} ->
      main.update_graph({:temp, sensor_id, temperature})
    end)

    send_resp(conn, 200, "ok")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
