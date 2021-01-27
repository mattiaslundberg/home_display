defmodule HomeDisplay.KrisinformationPollerTest do
  use ExUnit.Case, async: true
  alias HomeDisplay.KrisinformationPoller

  test "parse response" do
    body = File.read!("test/data/krisinformation.json")
    response = {:ok, %{body: body}} |> KrisinformationPoller.handle_response()
    assert is_map(response)
    assert "Utrikesdepartement" <> _ = Map.get(response, "Summary")
  end
end
