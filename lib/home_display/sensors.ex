defmodule HomeDisplay.Sensors do
  defstruct [:scene_id, :scene_location, :label, :temperature_offset]

  def sensors do
    %{
      "smhi" => %__MODULE__{
        scene_id: :out_temp,
        scene_location: {0, 45},
        label: "O",
        temperature_offset: 0
      },
      "28-005eeb0000af" => %__MODULE__{
        scene_id: :local_temp,
        scene_location: {50, 45},
        label: "L",
        temperature_offset: -7.1
      },
      "28-01203582c136" => %__MODULE__{
        scene_id: :kitchen1,
        scene_location: {100, 45},
        label: "K",
        temperature_offset: 0
      },
      "28-012035895244" => %__MODULE__{
        scene_id: :kitchen,
        scene_location: {150, 45},
        label: "k",
        temperature_offset: 0
      }
    }
  end

  def get_sensor(sensor_id), do: Map.get(sensors(), sensor_id)

  def format_reading(sensor, raw_temperature \\ ".") do
    "#{sensor.label} #{format_temperature(sensor, raw_temperature)}"
  end

  def format_temperature(sensor, t) when is_float(t),
    do: round(t + sensor.temperature_offset)

  def format_temperature(_, t), do: t
end
