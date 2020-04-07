defmodule Vnu do
  alias Vnu.{Config, HTTP, Error, Response}

  @doc ~S"""
  Validates the given HTML string.

  Returns %Vnu.Response{} if the validation process finished successfully, and %Vnu.Error{} otherwise.

  ## Examples

      iex> Vnu.validate("<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"utf-8\">\n</head>\n</html>", server_url: "http://localhost:8888")
      {:ok, %Vnu.Response{messages: [
        %Vnu.Message{
          type: :error,
          message: "Element “head” is missing a required instance of child element “title”.",
          extract: "=\"utf-8\">\n</head>\n</htm",
          last_line: 5,
          first_column: 1,
          last_column: 7,
          hilite_length: 7,
          hilite_start: 10
        },
        %Vnu.Message{
          type: :info,
          sub_type: :warning,
          extract: "TYPE html>\n<html>\n<head",
          first_line: 1,
          last_line: 2,
          first_column: 16,
          last_column: 6,
          hilite_length: 7,
          hilite_start: 10,
          message: "Consider adding a “lang” attribute to the “html” start tag to declare the language of this document."
        }
      ]}}

      iex> Vnu.validate("", server_url: "http://wrong-domain")
      {:error, %Vnu.Error{reason: :unexpected_server_response, message: "Could not contact the server, got error: %HTTPoison.Error{id: nil, reason: :nxdomain}"}}
  """

  @spec validate(String.t(), Keyword.t()) :: {:ok, Response.t()} | {:error, Error.t()}
  def validate(html, opts \\ []) when is_bitstring(html) and is_list(opts) do
    with {:ok, config} <- Config.new(opts),
         {:ok, response} <- HTTP.get_response(html, config) do
      {:ok, response}
    else
      error -> error
    end
  end
end
