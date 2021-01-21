defmodule HomeDisplay.Scene.Main do
  use Scenic.Scene
  alias Scenic.Graph

  import Scenic.Primitives

  @font_size 20
  @font :roboto

  def init(_, _) do
    graph =
      Graph.build(font_size: @font_size, font: @font, theme: :light, id: :main_graph)
      |> text("Outside: XX",
        font_size: @font_size,
        fill: :black,
        translate: {0, 20},
        id: :temp
      )

    state = %{
      graph: graph
    }

    {:ok, state, push: graph}
  end

  def update_temp(new_temp) do
    Scenic.Scene.cast(get_ref(), {:new_temp, new_temp})
  end

  def handle_cast({:new_temp, new_temp}, state = %{graph: graph}) do
    graph =
      graph
      |> Graph.modify(:temp, &text(&1, "Outside: #{new_temp}", []))

    {:noreply, state, push: graph}
  end

  defp get_ref() do
    {:ok, %{root_graph: {_, ref, _}}} = Scenic.ViewPort.info(:main_viewport)
    ref
  end
end
