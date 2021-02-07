defmodule HomeDisplay.Sources.KrisinformationPollerTest do
  use ExUnit.Case, async: true
  alias HomeDisplay.Sources.KrisinformationPoller

  test "parse response" do
    body = File.read!("test/data/krisinformation.json")
    response = {:ok, %{body: body}} |> KrisinformationPoller.handle_response()
    assert is_map(response)
    assert "Utrikesdepartement" <> _ = Map.get(response, "Summary")
  end

  test "parse response remove non relevant" do
    body = File.read!("test/data/krisinformation2.json")
    response = {:ok, %{body: body}} |> KrisinformationPoller.handle_response()
    assert is_map(response)
    assert "Regeringen har beslutat" <> _ = Map.get(response, "Summary")
  end
end
