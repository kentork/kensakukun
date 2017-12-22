defmodule Kensakukun.Elasticsearch do
  def get_indices() do
    host = Application.fetch_env!(:kensakukun, :es_host)
    port = Application.fetch_env!(:kensakukun, :es_port)

    HTTPotion.get("http://" <> host <> ":" <> port <> "/_cat/indices?format=json")
    |> Map.get(:body)
    |> Poison.decode!()
  end

  def search_path(index, query) do
    host = Application.fetch_env!(:kensakukun, :es_host)
    port = Application.fetch_env!(:kensakukun, :es_port)

    HTTPotion.get(
      "http://" <> host <> ":" <> port <> "/" <> index <> "/pathes/_search",
      headers: ["Content-Type": "application/json"],
      body: "{\"from\":0,\"size\":1000,\"query\": {\"term\": {\"path\": \"" <> query <> "\"}}}"
    )
    |> Map.get(:body)
    |> Poison.decode!()
    |> entities
    |> Enum.map(& &1["_source"])
  end

  defp entities(%{"hits" => %{"hits" => result}}), do: result
  # defp ok({:ok, result}), do: result
end
