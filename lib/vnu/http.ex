defmodule Vnu.HTTP do
  @moduledoc false

  alias Vnu.{Error, Message, Result}

  @doc false
  def get_result(html, config) do
    uri = URI.parse(config.server_url)
    query = Map.merge(uri.query || %{}, %{out: "json"})

    url =
      uri
      |> URI.merge(%URI{query: URI.encode_query(query)})
      |> URI.to_string()

    content_type =
      case config.format do
        :html -> "text/html"
        :css -> "text/css"
        :svg -> "image/svg+xml"
      end

    headers = [{"Content-Type", "#{content_type}; charset=utf-8"}]

    case config.http_client.post(url, html, headers) do
      {:ok, %{body: body, status: 200}} ->
        parse_body(body)

      {:ok, %{body: body, status: status}} ->
        {:error,
         Error.new(
           :unexpected_server_response,
           "Expected the server to respond with status code 200, instead got #{status} with body: #{
             inspect(body)
           }"
         )}

      {:error, error} ->
        {:error,
         Error.new(
           :unexpected_server_response,
           "Could not contact the server, got error: #{inspect(error)}"
         )}
    end
  end

  defp parse_body(response) do
    case Jason.decode(response) do
      {:ok, json} ->
        messages =
          json
          |> Map.get("messages", [])
          |> Enum.map(&Message.from_http_response(&1))

        {:ok, %Result{messages: messages}}

      {:error, _} ->
        {:error,
         Error.new(
           :unexpected_server_response,
           "Expected the server to respond with a valid JSON, instead got: #{inspect(response)}"
         )}
    end
  end
end
