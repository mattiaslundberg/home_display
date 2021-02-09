defmodule HomeDisplay.Sources.KrisinformationPollerTest do
  use ExUnit.Case, async: true
  alias HomeDisplay.Sources.KrisinformationPoller

  test "parse response" do
    body = File.read!("test/data/krisinformation.json")
    response = {:ok, %{body: body}} |> KrisinformationPoller.handle_response()
    assert is_map(response)
    assert "Reseavrådan till" <> _ = Map.get(response, "Title")
  end

  test "parse response remove non relevant" do
    body = File.read!("test/data/krisinformation2.json")
    response = {:ok, %{body: body}} |> KrisinformationPoller.handle_response()
    assert is_map(response)
    assert "Regeringen förlänger" <> _ = Map.get(response, "Title")
  end

  test "no events" do
    body = "{\"Entries\": []}"
    response = {:ok, %{body: body}} |> KrisinformationPoller.handle_response()
    assert is_map(response)
    assert "" = Map.get(response, "Title", "")
  end
end
