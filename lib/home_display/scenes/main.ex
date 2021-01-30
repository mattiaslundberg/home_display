defmodule HomeDisplay.Scene.Main do
  use Scenic.Scene
  alias Scenic.Graph

  import Scenic.Primitives
  alias HomeDisplay.Sensors

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

    graph =
      Enum.reduce(Sensors.sensors(), graph, fn {_s_id, s}, g ->
        text(g, Sensors.format_reading(s),
          font_size: @font_size,
          fill: :black,
          translate: s.scene_location,
          id: s.scene_id
        )
      end)

    {:ok, %{graph: graph}, push: graph}
  end

  def update_graph(action) when is_tuple(action) do
    Scenic.Scene.cast(get_ref(), action)
  end

  def handle_cast({:temp, sensor_id, raw_temperature}, state = %{graph: graph}) do
    graph =
      case Sensors.get_sensor(sensor_id) do
        nil ->
          graph

        %Sensors{scene_id: scene_id} = sensor ->
          content = Sensors.format_reading(sensor, raw_temperature)
          Graph.modify(graph, scene_id, &text(&1, content, []))
      end

    {:noreply, %{state | graph: graph}, push: graph}
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
