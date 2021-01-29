defmodule HomeDisplay.OneWireTests do
  use ExUnit.Case

  test "parse_data" do
    raw_data = "ae 01 0e 04 7f ff 02 10 5e : crc=5e YES\nae 01 0e 04 7f ff 02 10 5e t=26875 "

    assert 26.9 == OneWire.parse_data(raw_data)
  end
end
