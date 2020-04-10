defmodule Vnu.Message do
  @moduledoc """
  A message is a unit of information returned by the Checker.
  See [its documentation](https://github.com/validator/validator/wiki/Output-%C2%BB-JSON#media-type) for detailed up to date information about its output format.

  ## Fields

  - `:type` - One of `:error`, `:info`, or `:non_document_error`. Info messages can either be general information or warnings, see `:sub_type`.
      Non-document errors signify errors with the Checker server itself, and are treated internally by this library as if the validation could not be run at all.
  - `:sub_type` - For messages of type `:error` it could be  `nil` or `:fatal`. For messages of type `:info`, it could be `nil` or `:warning`.
  - `:message` - The detailed description of the issue.
  - `:extract` - The snippet of the document that the message is about.
  -  `:first_line`, `:last_line`, `:first_column`, `:last_column` - The position of the part of the document the message is about relative to the whole document.
      Lines and columns are numbered from 1.
  - `:hilite_start`, `:hilite_length` - Indicate the start and length of substring of the `:extract` that the message is roughly about.
      The characters are numbered from 0.
  """
  defstruct([
    :type,
    :sub_type,
    :message,
    :extract,
    :offset,
    :first_line,
    :first_column,
    :last_line,
    :last_column,
    :hilite_start,
    :hilite_length
  ])

  @type t :: %__MODULE__{
          type: :error | :info | :non_document_error,
          sub_type: :warning | :fatal | :io | :schema | :internal | nil,
          message: String.t() | nil,
          extract: String.t() | nil,
          offset: integer() | nil,
          first_line: integer() | nil,
          first_column: integer() | nil,
          last_line: integer() | nil,
          last_column: integer() | nil,
          hilite_start: integer() | nil,
          hilite_length: integer() | nil
        }

  @doc false
  def from_http_response(map) do
    message = %__MODULE__{
      type: get_type(map),
      sub_type: get_sub_type(map),
      message: get_string(map, "message"),
      extract: get_string(map, "extract"),
      offset: get_integer(map, "offset"),
      first_line: get_integer(map, "firstLine"),
      first_column: get_integer(map, "firstColumn"),
      last_line: get_integer(map, "lastLine"),
      last_column: get_integer(map, "lastColumn"),
      hilite_start: get_integer(map, "hiliteStart"),
      hilite_length: get_integer(map, "hiliteLength")
    }

    if message.last_line && !message.first_line do
      %{message | first_line: message.last_line}
    else
      message
    end
  end

  defp get_type(map) do
    case Map.get(map, "type") do
      "error" -> :error
      "info" -> :info
      "non-document-error" -> :non_document_error
    end
  end

  defp get_sub_type(map) do
    case Map.get(map, "subType") do
      "warning" -> :warning
      "fatal" -> :fatal
      "io" -> :io
      "schema" -> :schema
      "internal" -> :internal
      _ -> nil
    end
  end

  defp get_string(map, key) do
    case Map.get(map, key) do
      string when is_bitstring(string) -> string
      _ -> nil
    end
  end

  defp get_integer(map, key) do
    case Map.get(map, key) do
      integer when is_integer(integer) -> integer
      _ -> nil
    end
  end
end
