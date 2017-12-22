defmodule Kensakukun.Plug.Router do
  use Plug.Router
  require Logger

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)

  plug(:match)
  plug(:dispatch)

  get "/api/oauth/google/client_id" do
    client_id = Application.fetch_env!(:kensakukun, :api_token)
    resp(conn, 200, client_id)
  end

  get "/api/search" do
    index =
      Kensakukun.Elasticsearch.get_indices()
      |> Enum.max_by(&Integer.parse(&1["index"]))

    result = Kensakukun.Elasticsearch.search_path(index["index"], conn.params["query"])

    pathes =
      Poison.encode(result)
      |> (fn {:ok, result} -> result end).()

    resp(conn, 200, pathes)
  end

  match _ do
    resp(conn, 404, "Not Found")
  end
end
