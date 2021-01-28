defmodule HomeDisplay.TemperatureSeries do
  use Instream.Series

  series do
    database("home")
    measurement("temperature")

    tag(:location)

    field(:value)
  end
end
