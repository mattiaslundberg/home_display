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
      |> text("O XX",
        font_size: @font_size,
        fill: :black,
        translate: {0, 20},
        id: :out_temp
      )
      # |> text("I XX",
      #   font_size: @font_size,
      #   fill: :black,
      #   translate: {0, 35},
      #   id: :in_temp
      # )
      |> text("Event",
        font_size: @font_size,
        fill: :black,
        translate: {60, 20},
        id: :event
      )
      |> text("",
        font_size: @font_size,
        fill: :black,
        translate: {60, 35},
        id: :event_time
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

  defp get_ref() do
    {:ok, %{root_graph: {_, ref, _}}} = Scenic.ViewPort.info(:main_viewport)
    ref
  end
end
