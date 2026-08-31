defmodule Vnu.HTTPClient.Httpc do
  @moduledoc """
  `:httpc`-based HTTP client adapter (default).

  Relies on `:httpc`'s built-in secure TLS defaults (peer certificate verification against the
  OS trust store, hostname checking) for `https://` requests, available since Erlang/OTP 26.0.
  On older OTP versions, `:httpc` does not verify certificates by default; if you need to
  support an older OTP, implement your own `Vnu.HTTPClient` instead of relying on this adapter.
  """

  @behaviour Vnu.HTTPClient

  @impl true
  def post(url, body, headers) do
    # despite listing `:inets` and `:ssl` in `extra_applications`,
    # they may not be started when the vnu dependency is added with `runtime: false`
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    {content_type, headers} = pop_content_type(headers)

    headers = Enum.map(headers, fn {key, value} -> {String.to_charlist(key), value} end)

    # vnu returns an error if the User-Agent header is not set
    headers = [{~c"User-Agent", "vnu-elixir"} | headers]

    request =
      {String.to_charlist(url), headers, String.to_charlist(content_type), body}

    options = [body_format: :binary]

    case :httpc.request(:post, request, [], options) do
      {:ok, {{_http_version, status, _reason_phrase}, _resp_headers, resp_body}} ->
        {:ok, %{status: status, body: resp_body}}

      {:error, _reason} = error ->
        error
    end
  end

  defp pop_content_type(headers) do
    {[{"Content-Type", content_type}], other_headers} =
      Enum.split_with(headers, fn {key, _value} -> key == "Content-Type" end)

    {content_type, other_headers}
  end
end
