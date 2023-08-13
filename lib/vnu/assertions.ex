defmodule Vnu.Assertions do
  @moduledoc "ExUnit assertions for checking the validity of HTML, CSS, and SVG documents."

  alias Vnu.{CLI, Formatter}

  @doc """
  Asserts that the given HTML document is valid.

  ## Options

  - `:server_url` - The URL of [the Checker server](https://github.com/validator/validator). Defaults to `http://localhost:8888`.
  - `:fail_on_warnings` - Messages of type `:info` and subtype `:warning` will be treated as if they were validation errors.
    Their presence will mean the document is invalid. Defaults to `false`.
  - `:filter` - A module implementing the `Vnu.MessageFilter` behavior that will be used to exclude messages matching the filter from the result.
    Defaults to `nil` (no excluded messages).
  - `:http_client` - A module implementing the `Vnu.HTTPClient` behaviour that will be used to make the HTTP request to the server.
    Defaults to `Vnu.HTTPClient.Hackney`.
  - `:message_print_limit` - The maximum number of validation messages that will me printed in the error when the assertion fails.
    Can be an integer or `:infinity`. Defaults to `:infinity`.
  """
  def assert_valid_html(html, opts \\ []) do
    assert_valid(html, :html, opts)
  end

  @doc """
  Asserts that the given CSS document is valid.

  See `assert_valid_html/2` for the list of options and other details.
  """
  def assert_valid_css(css, opts \\ []) do
    assert_valid(css, :css, opts)
  end

  @doc """
  Asserts that the given SVG document is valid.

  See `assert_valid_html/2` for the list of options and other details.
  """
  def assert_valid_svg(svg, opts \\ []) do
    assert_valid(svg, :svg, opts)
  end

  @doc false
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp assert_valid(string, format, opts) do
    {validate_function, label} = CLI.format_to_function_and_pretty_name(format)

    case validate_function.(string, opts) do
      {:ok, result} ->
        if Vnu.valid?(result, opts) do
          string
        else
          fail_on_warnings? = Keyword.get(opts, :fail_on_warnings, false)
          message_print_limit = Keyword.get(opts, :message_print_limit, :infinity)
          grouped = Enum.group_by(result.messages, & &1.type)

          errors = Map.get(grouped, :error, [])
          infos = Map.get(grouped, :info, [])
          warnings = Enum.filter(infos, &(&1.sub_type == :warning))
          error_count = Enum.count(errors)
          warning_count = Enum.count(warnings)
          counts = %{error_count: error_count, warning_count: warning_count, info_count: nil}

          format_count_opts = [
            exclude_zeros: true,
            exclude_infos: true,
            with_colors: false
          ]

          {messages, expected_string} =
            if fail_on_warnings? do
              {errors ++ warnings, Formatter.format_counts(counts, format_count_opts)}
            else
              {errors,
               Formatter.format_counts(
                 counts,
                 Keyword.merge(format_count_opts, exclude_warnings: true)
               )}
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

          # credo:disable-for-lines:6 Credo.Check.Refactor.Nesting
          error_message =
            if omitted_messages_number > 0 do
              error_message <> "\n...and #{omitted_messages_number} more.\n"
            else
              error_message
            end

          raise ExUnit.AssertionError,
            message: error_message
        end

      {:error, error} ->
        reason =
          case error.reason do
            :unexpected_server_response -> "an unexpected response from the server"
            :invalid_config -> "an invalid configuration"
          end

        raise ExUnit.AssertionError,
          message: """
          Could not validate the #{label} document due to #{reason}:
          "#{error.message}"
          """
    end
  end
end
