defmodule HomeDisplay.Sources.Pollen do
  use GenServer
  require Logger
  alias HomeDisplay.Scene.Main

  @wait_between 3_600_000
  @url "https://pollenrapporten.se/4.549d670913d8d81d158347/12.549d670913d8d81d158351.portlet?state=rss&sv.contenttype=text/xml;charset=UTF-8"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl GenServer
  def init(_) do
    Process.send_after(self(), :check, 3000)

    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:check, state) do
    Process.send_after(self(), :check, @wait_between)

    data =
      Tesla.get(@url)
      |> handle_response()

    Main.update_graph({:pollen, "#{data}"})
    {:noreply, state}
  end

  def handle_response({:ok, %{body: body}}) do
    case Floki.parse_document(body) do
      {:ok, document} ->
        document
        |> Floki.find("item title")
        |> List.first()
        |> Floki.text()

      _ ->
        "Not parseable"
    end
  end

  def handle_response(_), do: "No response"
end
