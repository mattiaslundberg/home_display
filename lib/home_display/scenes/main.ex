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
      |> text("",
        font_size: @font_size,
        fill: :black,
        translate: {0, 15},
        id: :today
      )
      |> text("O XX",
        font_size: @font_size,
        fill: :black,
        translate: {0, 30},
        id: :out_temp
      )
      |> line({{0, 33}, {212, 33}}, fill: :black)
      |> line({{59, 0}, {59, 33}}, fill: :black)
      # |> text("I XX",
      #   font_size: @font_size,
      #   fill: :black,
      #   translate: {0, 50},
      #   id: :in_temp
      # )
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
        translate: {0, 94},
        id: :kris
      )

    state = %{
      graph: graph
    }

    {:ok, state, push: graph}
  end

  def update_out_temp(new_temp) do
    Scenic.Scene.cast(get_ref(), {:new_out_temp, new_temp})
  end

  def update_event(event) do
    Scenic.Scene.cast(get_ref(), {:new_event, event})
  end

  def update_today(date) do
    Scenic.Scene.cast(get_ref(), {:set_date, date})
  end

  def update_krisinformation(text) do
    Scenic.Scene.cast(get_ref(), {:set_kris, text})
  end

  def handle_cast({:new_out_temp, new_temp}, state = %{graph: graph}) do
    graph =
      graph
      |> Graph.modify(:out_temp, &text(&1, "O #{new_temp}", []))

    {:noreply, %{state | graph: graph}, push: graph}
  end

  def handle_cast({:new_event, event}, state = %{graph: graph}) when is_map(event) do
    graph =
      graph
      |> Graph.modify(:event, &text(&1, event.summary, []))
      |> Graph.modify(
        :event_time,
        &text(&1, event.start |> Timex.format!("{D}/{M} {h24}:{m}"), [])
      )

    {:noreply, %{state | graph: graph}, push: graph}
  end

  def handle_cast({:new_event, _}, state), do: {:noreply, state}

  def handle_cast({:set_date, date}, state = %{graph: graph}) do
    graph =
      graph
      |> Graph.modify(:today, &text(&1, Timex.format!(date, "{D}/{M}"), []))

    {:noreply, %{state | graph: graph}, push: graph}
  end

  def handle_cast({:set_kris, text}, state) do
    graph =
      state.graph
      |> Graph.modify(:kris, &text(&1, text))

    {:noreply, %{state | graph: graph}, push: graph}
  end

  defp get_ref() do
    {:ok, %{root_graph: {_, ref, _}}} = Scenic.ViewPort.info(:main_viewport)
    ref
  end
end
