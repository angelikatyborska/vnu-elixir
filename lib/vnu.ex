defmodule Vnu do
  alias Vnu.{Config, HTTP, Error, Response}

  @doc ~S"""
  Validates the given HTML.

  Returns %Vnu.Response{} if the validation process finished successfully, and %Vnu.Error{} otherwise.

  ## Examples

      iex> Vnu.validate_html("<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"utf-8\">\n</head>\n</html>", server_url: "http://localhost:8888")
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
          message: "Consider adding a “lang” attribute to the “html” start tag to declare the language of this document.",
          extract: "TYPE html>\n<html>\n<head",
          first_line: 1,
          last_line: 2,
          first_column: 16,
          last_column: 6,
          hilite_length: 7,
          hilite_start: 10,
        }
      ]}}

      iex> Vnu.validate_html("", server_url: "http://wrong-domain")
      {:error, %Vnu.Error{reason: :unexpected_server_response, message: "Could not contact the server, got error: %HTTPoison.Error{id: nil, reason: :nxdomain}"}}
  """

  @spec validate_html(String.t(), Keyword.t()) :: {:ok, Response.t()} | {:error, Error.t()}
  def validate_html(html, opts \\ []) when is_bitstring(html) and is_list(opts) do
    do_validate(html, Keyword.merge(opts, format: :html))
  end

  @doc ~S"""
  Validates the given CSS.

  Returns %Vnu.Response{} if the validation process finished successfully, and %Vnu.Error{} otherwise.

  ## Examples

      iex> Vnu.validate_css(".button { display: banana; }", server_url: "http://localhost:8888")
      {:ok, %Vnu.Response{messages: [
        %Vnu.Message{
          type: :error,
          message: "“display”: “banana” is not a “display” value.",
          extract: ".button { display: banana; }\n",
          last_line: 1,
          first_column: 20,
          last_column: 25,
          hilite_length: 6,
          hilite_start: 19,
        }
      ]}}

      iex> Vnu.validate_css("", server_url: "http://wrong-domain")
      {:error, %Vnu.Error{reason: :unexpected_server_response, message: "Could not contact the server, got error: %HTTPoison.Error{id: nil, reason: :nxdomain}"}}
  """

  @spec validate_css(String.t(), Keyword.t()) :: {:ok, Response.t()} | {:error, Error.t()}
  def validate_css(css, opts \\ []) when is_bitstring(css) and is_list(opts) do
    do_validate(css, Keyword.merge(opts, format: :css))
  end

  @doc ~S"""
  Validates the given SVG.

  Returns %Vnu.Response{} if the validation process finished successfully, and %Vnu.Error{} otherwise.

  ## Examples

      iex> Vnu.validate_svg(~S(
      ...>  <svg width="5cm" height="4cm" version="1.1" xmlns="http://www.w3.org/2000/svg">
      ...>  <desc>Rectangle</desc>
      ...>  <rect x="0.5cm" y="0.5cm" height="1cm"/>
      ...>  </svg>
      ...> ), server_url: "http://localhost:8888")
      {:ok, %Vnu.Response{messages: [
        %Vnu.Message{
          type: :info,
          message: "Using the preset for SVG 1.1 + URL + HTML + MathML 3.0 based on the root namespace."
        },
        %Vnu.Message{
          type: :error,
          message: "SVG element “rect” is missing required attribute “width”.",
          extract: "</desc>\n  <rect x=\"0.5cm\" y=\"0.5cm\" height=\"1cm\"/>\n  </s",
          last_line: 4,
          first_column: 3,
          last_column: 42,
          hilite_length: 40,
          hilite_start: 10,
        }
      ]}}

      iex> Vnu.validate_svg("", server_url: "http://wrong-domain")
      {:error, %Vnu.Error{reason: :unexpected_server_response, message: "Could not contact the server, got error: %HTTPoison.Error{id: nil, reason: :nxdomain}"}}
  """

  @spec validate_svg(String.t(), Keyword.t()) :: {:ok, Response.t()} | {:error, Error.t()}
  def validate_svg(svg, opts \\ []) when is_bitstring(svg) and is_list(opts) do
    do_validate(svg, Keyword.merge(opts, format: :svg))
  end

  defp do_validate(string, opts) do
    with {:ok, config} <- Config.new(opts),
         {:ok, response} <- HTTP.get_response(string, config) do
      {:ok, response}
    else
      error -> error
    end
  end
end
