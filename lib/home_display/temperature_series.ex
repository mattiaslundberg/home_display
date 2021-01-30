defmodule HomeDisplay.TemperatureSeries do
  use Instream.Series

  series do
    database("home")
    measurement("temperature")

    tag(:location)
    tag(:sensor_id)

    field(:value)
  end
end
