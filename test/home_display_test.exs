defmodule HomeDisplayTest do
  use ExUnit.Case, async: true
  doctest HomeDisplay

  test "greets the world" do
    assert HomeDisplay.hello() == :world
  end
end
