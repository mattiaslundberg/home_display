defmodule HomeDisplay.SensorsTest do
  use ExUnit.Case, async: true
  alias HomeDisplay.Sensors

  test "get existing sensor" do
    assert %{scene_id: :out_temp} = Sensors.get_sensor("smhi")
  end

  test "get non existing sensor" do
    refute Sensors.get_sensor("nonexisting")
  end

  describe "format_reading/2" do
    test "no temperature" do
      sensor = Sensors.get_sensor("smhi")

      assert "O ." = Sensors.format_reading(sensor)
    end

    test "float temperature" do
      sensor = Sensors.get_sensor("smhi")

      assert "O 3.9" = Sensors.format_reading(sensor, 3.899)
    end

    test "string temperature" do
      sensor = Sensors.get_sensor("smhi")

      assert "O 8.93" = Sensors.format_reading(sensor, "8.93")
    end
  end
end
