defmodule Vnu.Config do
  @moduledoc false

  alias Vnu.Error

  defstruct server_url: nil

  @defaults [server_url: "http://localhost:8888"]

  @doc false
  def new(opts) when is_list(opts) do
    opts = Keyword.merge(@defaults, opts)
    server_url = Keyword.get(opts, :server_url)

    if is_bitstring(server_url) do
      server_url = String.trim_trailing(server_url, "/")
      {:ok, %__MODULE__{server_url: server_url}}
    else
      {:error,
       Error.new(
         :invalid_config,
         "Expected server_url to be a string, got: #{inspect(server_url)}"
       )}
    end
  end
end
