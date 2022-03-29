defmodule Vnu.Formatter do
  @moduledoc false

  alias Vnu.Message

  import IO.ANSI, only: [red: 0, yellow: 0, blue: 0, cyan: 0, green: 0, reset: 0, reverse: 0]

  @doc false
  @spec format_messages(list(Message.t())) :: list(String.t())
  def format_messages(messages, file_path \\ nil) do
    messages
    |> sort()
    |> Enum.map(fn message ->
      type = type(message)
      color = color(message)

      location = format_location(message)
      extract = format_extract(message)

      header = "#{with_color("#{reverse()} #{type} ", color)} #{message.message}"
      left_padding = if file_path, do: with_color("┃ ", color), else: ""
      extract_with_location = extract_with_location(extract, location, left_padding, file_path)

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
  def format_counts(
        %{error_count: error_count, warning_count: warning_count, info_count: info_count},
        opts \\ []
      ) do
    exclude_zeros? = Keyword.get(opts, :exclude_zeros, false)
    exclude_warnings? = Keyword.get(opts, :exclude_warnings, false)
    exclude_infos? = Keyword.get(opts, :exclude_infos, false)
    with_colors? = Keyword.get(opts, :with_colors, true)

    error_count_phrase =
      phrase_maybe_with_color(
        "error",
        "errors",
        error_count,
        exclude_zeros?,
        error_color(),
        with_colors?
      )

    warning_count_phrase =
      phrase_maybe_with_color(
        "warning",
        "warnings",
        warning_count,
        exclude_zeros?,
        warning_color(),
        with_colors?
      )

    info_count_phrase =
      phrase_maybe_with_color(
        "info",
        "infos",
        info_count,
        exclude_zeros?,
        info_color(),
        with_colors?
      )

    phrases = []
    phrases = if exclude_infos?, do: phrases, else: [info_count_phrase | phrases]
    phrases = if exclude_warnings?, do: phrases, else: [warning_count_phrase | phrases]
    phrases = [error_count_phrase | phrases]

    phrases = Enum.filter(phrases, & &1)

    case phrases do
      [a, b, c] -> "#{a}, #{b}, and #{c}"
      [a, b] -> "#{a} and #{b}"
      [a] -> "#{a}"
      [] -> ""
    end
  end

  defp phrase_maybe_with_color(singular, plural, count, exclude_zeros?, color, with_color?) do
    phrase =
      case count do
        0 -> if exclude_zeros?, do: nil, else: "#{count} #{plural}"
        1 -> "#{count} #{singular}"
        _ -> "#{count} #{plural}"
      end

    if phrase && with_color? do
      with_color(phrase, color)
    else
      phrase
    end
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
  def success_color() do
    green()
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

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp extract_with_location(extract, location, left_padding, path) do
    if path do
      location = location_with_path(location, path)

      case extract do
        [extract, hilite] ->
          "#{left_padding}#{with_color(location, label_color())}\n" <>
            "#{left_padding}#{extract}\n" <>
            "#{left_padding}#{hilite}"

        [extract] ->
          "#{left_padding}#{with_color(location, label_color())}\n" <>
            "#{left_padding}#{extract}"

        nil ->
          "#{left_padding}#{with_color(location, label_color())}"
      end
    else
      location = location_without_path(location)

      case extract do
        [extract, hilite] ->
          "#{left_padding}#{if location, do: with_color(location, label_color())}#{extract}\n" <>
            "#{left_padding}#{if location, do: String.duplicate(" ", String.length(location))}#{hilite}"

        [extract] ->
          "#{left_padding}#{if location, do: with_color(location, label_color())}#{extract}"

        nil ->
          nil
      end
    end
  end

  defp location_with_path(location, path) do
    location =
      if location do
        location
        |> String.replace(~r/L/, "")
        |> String.replace(~r/-(.)*/, "")
      end

    if location do
      path <> ":" <> location
    else
      path
    end
  end

  defp location_without_path(location) do
    if location, do: "[#{location}] "
  end
end
