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
          else
            # TODO: do not print all messages if there is a lot, make the threshold customizable
            fail_on_warnings? = Keyword.get(unquote(opts), :fail_on_warnings, false)
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

            messages_string =
              Formatter.format_messages(messages)
              |> Enum.join("\n\n")

            flunk("""
            Expected the #{label} document to be valid, but got #{expected_string}

            #{messages_string}
            """)
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

  defmacro assert_valid_html(html, opts \\ []) do
    quote do
      assert_valid(unquote(html), :html, unquote(opts))
    end
  end

  defmacro assert_valid_css(css, opts \\ []) do
    quote do
      assert_valid(unquote(css), :css, unquote(opts))
    end
  end

  defmacro assert_valid_svg(svg, opts \\ []) do
    quote do
      assert_valid(unquote(svg), :svg, unquote(opts))
    end
  end
end
