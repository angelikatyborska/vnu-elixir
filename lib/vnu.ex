defmodule Vnu do
  alias Vnu.{Error, Response, Validator}

  @doc ~S"""
  Validates the given HTML.

  Returns %Vnu.Response{} if the validation process finished successfully, and %Vnu.Error{} otherwise.

  ## Examples

      iex> Vnu.validate_html(~S(
      ...><!DOCTYPE html>
      ...><html>
      ...><head>
      ...>  <meta charset="utf-8">
      ...></head>
      ...><body>
      ...></body>
      ...></html>
      ...>), server_url: "http://localhost:8888")
      {:ok, %Vnu.Response{messages: [
        %Vnu.Message{
          type: :error,
          message: "Element “head” is missing a required instance of child element “title”.",
          extract: "=\"utf-8\">\n</head>\n<body",
          first_line: 6,
          last_line: 6,
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
          first_line: 2,
          last_line: 3,
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
    Validator.validate(html, Keyword.merge(opts, format: :html))
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
          first_line: 1,
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
    Validator.validate(css, Keyword.merge(opts, format: :css))
  end

  @doc ~S"""
  Validates the given SVG.

  Returns %Vnu.Response{} if the validation process finished successfully, and %Vnu.Error{} otherwise.

  ## Examples

      iex> Vnu.validate_svg(~S(
      ...><svg width="5cm" height="4cm" version="1.1" xmlns="http://www.w3.org/2000/svg">
      ...><desc>Rectangle</desc>
      ...><rect x="0.5cm" y="0.5cm" height="1cm"/>
      ...></svg>
      ...> ), server_url: "http://localhost:8888")
      {:ok, %Vnu.Response{messages: [
        %Vnu.Message{
          type: :info,
          message: "Using the preset for SVG 1.1 + URL + HTML + MathML 3.0 based on the root namespace."
        },
        %Vnu.Message{
          type: :error,
          message: "SVG element “rect” is missing required attribute “width”.",
          extract: "le</desc>\n<rect x=\"0.5cm\" y=\"0.5cm\" height=\"1cm\"/>\n</svg",
          first_line: 4,
          last_line: 4,
          first_column: 1,
          last_column: 40,
          hilite_length: 40,
          hilite_start: 10,
        }
      ]}}

      iex> Vnu.validate_svg("", server_url: "http://wrong-domain")
      {:error, %Vnu.Error{reason: :unexpected_server_response, message: "Could not contact the server, got error: %HTTPoison.Error{id: nil, reason: :nxdomain}"}}
  """

  @spec validate_svg(String.t(), Keyword.t()) :: {:ok, Response.t()} | {:error, Error.t()}
  def validate_svg(svg, opts \\ []) when is_bitstring(svg) and is_list(opts) do
    Validator.validate(svg, Keyword.merge(opts, format: :svg))
  end
end
