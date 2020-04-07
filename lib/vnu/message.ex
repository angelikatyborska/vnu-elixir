defmodule Vnu.Message do
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
    %__MODULE__{
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
