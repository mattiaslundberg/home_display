defmodule HomeDisplay.Sensors do
  defstruct [:scene_id, :scene_location, :label, :temperature_offset]

  def sensors do
    %{
      "28-005eeb0000af" => %__MODULE__{
        scene_id: :local_temp,
        scene_location: {0, 65},
        label: "L",
        temperature_offset: -7.1
      },
      "smhi" => %__MODULE__{
        scene_id: :out_temp,
        scene_location: {0, 50},
        label: "O",
        temperature_offset: 0
      },
      "28-todo" => %__MODULE__{
        scene_id: :freezer_temp,
        scene_location: {0, 80},
        label: "F",
        temperature_offset: 0
      }
    }
  end

  def get_sensor(sensor_id), do: Map.get(sensors(), sensor_id)

  def format_reading(sensor, raw_temperature \\ ".") do
    "#{sensor.label} #{format_temperature(raw_temperature)}"
  end

  defp format_temperature(t) when is_float(t), do: Float.round(t, 1)
  defp format_temperature(t), do: t
end
