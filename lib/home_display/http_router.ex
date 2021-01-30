defmodule HomeDisplay.HttpRouter do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  post "/temperature" do
    {:ok, body, conn} = conn |> read_body()

    body
    |> Jason.decode!()
    |> Enum.each(fn {target, temperature} ->
      HomeDisplay.Scene.Main.update_graph(
        {String.to_existing_atom(target), "R #{round(temperature)}"}
      )
    end)

    send_resp(conn, 200, "ok")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
