defmodule Vnu do
  alias Vnu.{Config, HTTP, Error}

  @spec validate(String.t(), Keyword.t()) :: {:ok, %{}} | {:error, Error.t()}
  def validate(html, opts \\ []) when is_bitstring(html) and is_list(opts) do
    with {:ok, config} <- Config.new(opts),
         {:ok, response} <- HTTP.get_response(html, config) do
      response
    else
      error -> error
    end
  end
end
