defmodule Vnu.Assertions do
  @moduledoc "ExUnit assertions for checking the validity of HTML, CSS, and SVG documents."

  alias Vnu.{Formatter}

  @doc false
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defmacro assert_valid(string, format, opts \\ []) do
    quote do
      {validate_function, label} =
        case unquote(format) do
          :html -> {&Vnu.validate_html/2, "HTML"}
          :css -> {&Vnu.validate_css/2, "CSS"}
          :svg -> {&Vnu.validate_svg/2, "SVG"}
        end

      case validate_function.(unquote(string), unquote(opts)) do
        {:ok, result} ->
          if Vnu.valid?(result, unquote(opts)) do
            assert true
            unquote(string)
          else
            fail_on_warnings? = Keyword.get(unquote(opts), :fail_on_warnings, false)
            message_print_limit = Keyword.get(unquote(opts), :message_print_limit, :infinity)
            grouped = Enum.group_by(result.messages, & &1.type)

            errors = Map.get(grouped, :error, [])
            infos = Map.get(grouped, :info, [])
            warnings = Enum.filter(infos, &(&1.sub_type == :warning))
            error_count = Enum.count(errors)
            warning_count = Enum.count(warnings)

            error_count_phrase =
              case error_count do
                0 -> nil
                1 -> "#{error_count} error"
                n -> "#{error_count} errors"
              end

            warning_count_phrase =
              case warning_count do
                0 -> nil
                1 -> "#{warning_count} warning"
                n -> "#{warning_count} warnings"
              end

            {messages, expected_string} =
              if fail_on_warnings? do
                {errors ++ warnings,
                 Enum.filter([error_count_phrase, warning_count_phrase], & &1)
                 |> Enum.join(" and ")}
              else
                {errors, error_count_phrase}
              end

            {messages_to_be_printed, omitted_messages_number} =
              if message_print_limit != :infinity && message_print_limit < Enum.count(messages) do
                {Enum.take(Formatter.sort(messages), message_print_limit),
                 Enum.count(messages) - message_print_limit}
              else
                {messages, 0}
              end

            messages_string =
              Formatter.format_messages(messages_to_be_printed)
              |> Enum.join("\n\n")

            error_message = """
            Expected the #{label} document to be valid, but got #{expected_string}

            #{messages_string}
            """

            error_message =
              if omitted_messages_number > 0 do
                error_message <> "\n...and #{omitted_messages_number} more.\n"
              else
                error_message
              end

            flunk(error_message)
          end

        {:error, error} ->
          reason =
            case error.reason do
              :unexpected_server_response -> "an unexpected response from the server"
              :invalid_config -> "an invalid configuration"
            end

          flunk("""
          Could not validate the #{label} document due to #{reason}:
          "#{error.message}"
          """)
      end
    end
  end

  @doc """
  Asserts that the given HTML document is valid.

  ## Options

  - `:server_url` - The URL of [the Checker server](https://github.com/validator/validator). Defaults to `http://localhost:8888`.
  - `:fail_on_warnings` - Messages of type `:info` and subtype `:warning` will be treated as if they were validation errors.
  Their presence will mean the document is invalid. Defaults to `false`.
  - `message_print_limit` - THe maximum number of validation messages that will me printed in the error when the assertion fails.
  Can be an integer or `:infinity`. Defaults to `:infinity`.
    - ':filter' - A module implementing the `Vnu.MessageFilter` behavior that will be used to exclude messages matching the filter from the result.
  Defaults to `nil` (no excluded messages).
  """
  defmacro assert_valid_html(html, opts \\ []) do
    quote do
      assert_valid(unquote(html), :html, unquote(opts))
    end
  end

  @doc """
  Asserts that the given CSS document is valid.

  See `assert_valid_html/1` for the list of options and other details.
  """
  defmacro assert_valid_css(css, opts \\ []) do
    quote do
      assert_valid(unquote(css), :css, unquote(opts))
    end
  end

  @doc """
  Asserts that the given SVG document is valid.

  See `assert_valid_html/1` for the list of options and other details.
  """
  defmacro assert_valid_svg(svg, opts \\ []) do
    quote do
      assert_valid(unquote(svg), :svg, unquote(opts))
    end
  end
end
