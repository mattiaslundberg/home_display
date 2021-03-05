defmodule HomeDisplay.Scene.Main do
  use Scenic.Scene
  alias Scenic.Graph

  import Scenic.Primitives
  alias HomeDisplay.Sensors

  @font_size 20
  @font :roboto

  @expire_every 2_500_000

  @callback update_graph(tuple()) :: atom()

  def init(_, _) do
    graph =
      Graph.build(font_size: @font_size, font: @font, id: :main_graph)
      |> rectangle({212, 104}, fill: :white)
      |> line({{0, 77}, {212, 77}}, fill: :black)
      |> text("",
        font_size: @font_size,
        fill: :black,
        translate: {0, 15},
        id: :today
      )
      |> text("",
        font_size: @font_size,
        fill: :black,
        translate: {45, 15},
        id: :day
      )
      |> line({{0, 25}, {212, 25}}, fill: :black)
      |> text("",
        font_size: @font_size,
        fill: :black,
        translate: {0, 73},
        id: :event
      )
      |> text("",
        font_size: @font_size - 4,
        fill: :black,
        translate: {0, 58},
        id: :event_time
      )
      |> text("",
        font_size: @font_size - 4,
        fill: :black,
        translate: {0, 102},
        id: :kris
      )
      |> text("",
        font_size: @font_size - 4,
        fill: :black,
        translate: {0, 89},
        id: :pollen
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

    :timer.send_interval(@expire_every, :expire_old)

    {:ok, %{graph: graph, last_updates: %{}}, push: graph}
  end

  def update_graph(action) when is_tuple(action) do
    Scenic.Scene.cast(get_ref(), action)
  end

  def handle_info(:expire_old, state = %{last_updates: last_updates, graph: graph}) do
    now = DateTime.utc_now()

    {graph, last_updates} =
      last_updates
      |> Enum.reduce({graph, %{}}, fn {scene_id, updated_at}, {graph, last_updates} ->
        if DateTime.diff(updated_at, now) |> abs() > 3600 do
          {expire_display(graph, scene_id), last_updates}
        else
          {graph, Map.put(last_updates, scene_id, updated_at)}
        end
      end)

    {:noreply, %{state | graph: graph, last_updates: last_updates}, push: graph}
  end

  def handle_cast({:temp, sensor_id, raw_temperature}, state) do
    case Sensors.get_sensor(sensor_id) do
      nil ->
        {:noreply, state}

      %Sensors{scene_id: scene_id} = sensor ->
        content = Sensors.format_reading(sensor, raw_temperature)
        do_update(state, scene_id, content)
    end
  end

  def handle_cast({target, content}, state), do: do_update(state, target, content)

  defp expire_display(graph, scene_id) do
    Graph.modify(graph, scene_id, &text(&1, "#", []))
  end

  defp do_update(state = %{graph: graph, last_updates: last_updates}, target, content)
       when is_binary(content) do
    last_updates = Map.put(last_updates, target, DateTime.utc_now())
    graph = Graph.modify(graph, target, &text(&1, content, []))
    {:noreply, %{state | graph: graph, last_updates: last_updates}, push: graph}
  end

  defp do_update(state, _, _), do: {:noreply, state}

  defp get_ref do
    {:ok, %{root_graph: {_, ref, _}}} = Scenic.ViewPort.info(:main_viewport)
    ref
  end
end
