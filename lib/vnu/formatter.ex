defmodule Vnu.Formatter do
  @moduledoc false

  alias Vnu.Message

  import IO.ANSI, only: [red: 0, yellow: 0, blue: 0, cyan: 0, reset: 0, reverse: 0]

  @doc false
  @spec format_messages(list(Message.t())) :: list(String.t())
  def format_messages(messages) do
    messages
    |> sort()
    |> Enum.map(fn message ->
      type = type(message)
      color = color(message)

      location = format_location(message)
      extract = format_extract(message)

      header = "#{with_color("#{reverse()} #{type} ", color)} #{message.message}"
      extract_with_location = extract_with_location(extract, location)

      [header, extract_with_location]
      |> Enum.filter(& &1)
      |> Enum.join("\n")
    end)
  end

  @doc false
  def sort(messages) do
    Enum.sort(messages, fn a, b ->
      al = a.first_line || 0
      bl = b.first_line || 0

      ac = a.first_column || 0
      bc = b.first_column || 0

      if al == bl do
        ac <= bc
      else
        al <= bl
      end
    end)
  end

  @doc false
  def with_color(string, color) do
    "#{color}#{string}#{reset()}"
  end

  @doc false
  def info_color() do
    blue()
  end

  @doc false
  def warning_color() do
    yellow()
  end

  @doc false
  def error_color() do
    red()
  end

  @doc false
  def label_color() do
    cyan()
  end

  defp type(%Message{} = message) do
    case message do
      %Message{type: :error} -> "Error"
      %Message{type: :info, sub_type: :warning} -> "Warning"
      %Message{type: :info, sub_type: nil} -> "Info"
    end
  end

  defp color(%Message{} = message) do
    case message do
      %Message{type: :error} -> error_color()
      %Message{type: :info, sub_type: :warning} -> warning_color()
      %Message{type: :info, sub_type: nil} -> info_color()
    end
  end

  defp format_location(%Message{} = message) do
    case message do
      %Message{first_line: nil, last_line: nil, first_column: nil, last_column: nil} ->
        nil

      %Message{first_line: l, last_line: l, first_column: nil, last_column: nil} ->
        "L#{l}"

      %Message{first_line: l1, last_line: l2, first_column: nil, last_column: nil} ->
        "L#{l1}-#{l2}"

      %Message{first_line: l, last_line: l, first_column: col1, last_column: col2} ->
        "L#{l}:#{col1}-#{col2}"

      %Message{first_line: l1, last_line: l2, first_column: col1, last_column: col2} ->
        "L#{l1}:#{col1}-L#{l2}:#{col2}"
    end
  end

  defp format_extract(%Message{} = message) do
    extract =
      if message.extract do
        String.replace(message.extract, "\n", "↩")
      end

    hilite =
      if extract && message.hilite_start && message.hilite_length do
        String.duplicate(" ", message.hilite_start) <>
          label_color() <>
          String.duplicate("^", message.hilite_length) <>
          reset()
      end

    if extract do
      if hilite, do: [extract, hilite], else: [extract]
    end
  end

  defp extract_with_location(extract, location) do
    location = if location, do: "[#{location}] "

    case extract do
      [extract, hilite] ->
        "#{if location, do: with_color(location, label_color())}#{extract}\n" <>
          "#{if location, do: String.duplicate(" ", String.length(location))}#{hilite}"

      [extract] ->
        "#{if location, do: with_color(location, label_color())}#{extract}"

      nil ->
        nil
    end
  end
end
