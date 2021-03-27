defmodule Vnu.HTTPClient do
  @moduledoc """
  Specification for a Vnu HTTP client.
  """

  @type url() :: String.t()
  @type body() :: String.t()
  @type header() :: {String.t(), String.t()}

  @type status() :: non_neg_integer()

  @type response() :: %{status: status(), body: body()}

  @doc """
  A callback to make a POST HTTP request.
  """
  @callback post(url(), body(), [header()]) :: {:ok, response()} | {:error, any()}
end
