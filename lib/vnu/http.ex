defmodule Vnu.HTTP do
  @moduledoc false

  alias Vnu.Error

  def get_response(html, config) do
    url = "#{config.server_url}?out=json"

    headers = [{"Content-Type", "text/html"}]

    case HTTPoison.post(url, html, headers) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        parse_body(body)

      {:ok, %HTTPoison.Response{body: body, status_code: status_code}} ->
        {:error,
         Error.new(
           :unexpected_server_response,
           "Expected the server to respond with status code 200, instead got #{status_code} with body: #{
             inspect(body)
           }"
         )}

      {:error, error} ->
        Error.new(
          :unexpected_server_response,
          "Could not contact the server, got error: #{inspect(error)} "
        )
    end
  end

  defp parse_body(response) do
    case Jason.decode(response) do
      {:ok, json} ->
        {:ok, json}

      {:error, _} ->
        {:error,
         Error.new(
           :unexpected_server_response,
           "Expected the server to respond with a valid JSON, instead got: #{inspect(response)}"
         )}
    end
  end
end
