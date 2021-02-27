defmodule HomeDisplay.Sources.PollenTest do
  use ExUnit.Case, async: true
  alias HomeDisplay.Sources.Pollen

  import Mox

  setup :verify_on_exit!

  describe "parse_title/1" do
    test "nothing matching" do
      assert Pollen.parse_title("Senast uppmätta halter") == ""
      assert Pollen.parse_title("") == ""
    end

    test "pollen in word" do
      assert Pollen.parse_title("alpollen.") == "al"
      assert Pollen.parse_title("hasselpollen låga halter") == "hassel"
    end

    test "multiple pollens" do
      assert Pollen.parse_title("hasselpollen låga halter. alpollen höga halter.") ==
               "hassel, al"
    end
  end
end
