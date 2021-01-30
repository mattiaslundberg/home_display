defmodule HomeDisplay.HttpRouter do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  post "/temperature" do
    {:ok, body, conn} = conn |> read_body()

    body
    |> Jason.decode!()
    |> Enum.each(fn {target, temperature} ->
      t = String.to_existing_atom(target)
      HomeDisplay.Scene.Main.update_graph({t, "#{target_label(t)} #{round(temperature)}"})
    end)

    send_resp(conn, 200, "ok")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp target_label(:freezer_temp), do: "F"
  defp target_label(_), do: "?"
end
