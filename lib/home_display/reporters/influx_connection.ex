defmodule HomeDisplay.Reporters.InfluxConnection do
  use Instream.Connection, otp_app: :home_display
  alias HomeDisplay.Reporters.TemperatureSeries

  @callback write(%TemperatureSeries{}) :: String.t()
end
