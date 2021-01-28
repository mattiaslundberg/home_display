defmodule HomeDisplay.Scene.Main do
  use Scenic.Scene
  alias Scenic.Graph

  import Scenic.Primitives

  @font_size 20
  @font :roboto

  def init(_, _) do
    graph =
      Graph.build(font_size: @font_size, font: @font, id: :main_graph)
      |> rectangle({212, 104}, fill: :white)
      |> line({{0, 33}, {212, 33}}, fill: :black)
      |> line({{0, 88}, {212, 88}}, fill: :black)
      |> line({{59, 0}, {59, 88}}, fill: :black)
      |> text("",
        font_size: @font_size,
        fill: :black,
        translate: {0, 15},
        id: :today
      )
      |> text("",
        font_size: @font_size,
        fill: :black,
        translate: {0, 30},
        id: :day
      )
      |> text("O XX",
        font_size: @font_size,
        fill: :black,
        translate: {0, 50},
        id: :out_temp
      )
      |> text("L XX",
        font_size: @font_size,
        fill: :black,
        translate: {0, 65},
        id: :local_temp
      )
      |> text("",
        font_size: @font_size,
        fill: :black,
        translate: {60, 15},
        id: :event
      )
      |> text("",
        font_size: @font_size,
        fill: :black,
        translate: {60, 30},
        id: :event_time
      )
      |> text("",
        font_size: @font_size - 4,
        fill: :black,
        translate: {0, 102},
        id: :kris
      )

    state = %{
      graph: graph
    }

    {:ok, state, push: graph}
  end

  def update_graph(action) when is_tuple(action) do
    Scenic.Scene.cast(get_ref(), action)
  end

  def handle_cast({target, content}, state = %{graph: graph}) do
    graph = Graph.modify(graph, target, &text(&1, content, []))

    {:noreply, %{state | graph: graph}, push: graph}
  end

  defp get_ref() do
    {:ok, %{root_graph: {_, ref, _}}} = Scenic.ViewPort.info(:main_viewport)
    ref
  end
end
