defmodule Vnu.HTTPClient.Hackney do
  @moduledoc """
  Hackney-based HTTP client adapter.
  """

  @behaviour Vnu.HTTPClient
  require Logger

  @impl true
  def post(url, body, headers) do
    if Code.ensure_loaded?(:hackney) do
      with {:ok, status, _headers, body_ref} <-
             :hackney.request(:post, url, headers, body, follow_redirect: true),
           {:ok, body} <- :hackney.body(body_ref) do
        {:ok, %{status: status, body: body}}
      else
        {:error, error} ->
          {:error, error}

        {:connect_error, {:error, error}} ->
          {:error, error}
      end
    else
      Logger.error("""
      Could not find hackney dependency.

      Please add :hackney to your dependencies:

          {:hackney, "~> 1.17"}

      Or use a different HTTP client. See Vnu.HTTPClient for more information.
      """)

      raise "missing hackney dependency"
    end
  end
end
