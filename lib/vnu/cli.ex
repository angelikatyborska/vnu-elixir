defmodule Vnu.CLI do
  @moduledoc false

  alias Vnu.Formatter

  @doc false
  @spec validate(list(), atom()) :: no_return()
  def validate(argv, format) do
    {opts, files, invalid_args} =
      OptionParser.parse(argv,
        strict: [server_url: :string, fail_on_warnings: :boolean, filter: :string]
      )

    if invalid_args != [] do
      print_usage_info(format)
      Mix.raise("Invalid options: #{inspect(invalid_args)}")
    end

    if files == [] do
      print_usage_info(format)
      Mix.raise("No files given")
    end

    opts = Keyword.update(opts, :filter, nil, &Module.concat([&1]))

    if Keyword.get(opts, :filter, nil) do
      # must compile to ensure the filter module is available
      Mix.Task.run("compile", [])
    end

    fail_on_warnings? = Keyword.get(opts, :fail_on_warnings, false)

    {validate_function, pretty_name} = format_to_function_and_pretty_name(format)

    Mix.shell().info("\nValidating #{pretty_name} files:")
    file_list = Enum.join(Enum.map(files, &"  - #{&1}"), "\n")
    Mix.shell().info(file_list <> "\n")

    Application.ensure_all_started(:hackney)

    results =
      Enum.map(files, fn file ->
        with {:file, {:ok, document}} <- {:file, File.read(file)},
             {:validation, {:ok, result}} <- {:validation, validate_function.(document, opts)} do
          messages =
            result.messages
            |> Vnu.Formatter.sort()
            |> Vnu.Formatter.format_messages(file)
            |> Enum.join("\n\n")

          if String.trim(messages) != "" do
            Mix.shell().info(messages <> "\n")
          end

          grouped = Enum.group_by(result.messages, & &1.type)

          errors = Map.get(grouped, :error, [])
          infos = Map.get(grouped, :info, [])
          warnings = Enum.filter(infos, &(&1.sub_type == :warning))
          error_count = Enum.count(errors)
          warning_count = Enum.count(warnings)
          info_count = Enum.count(infos) - warning_count

          {file,
           %{error_count: error_count, warning_count: warning_count, info_count: info_count}}
        else
          {:file, {:error, error}} ->
            Mix.raise("File #{file} could not be read:\n  #{inspect(error)}")

          {:validation, {:error, error}} ->
            Mix.raise("Could not finish validating #{file}:\n  #{inspect(error)}")
        end
      end)

    total_counts = %{
      error_count: Enum.sum(Enum.map(results, fn {_, %{error_count: n}} -> n end)),
      warning_count: Enum.sum(Enum.map(results, fn {_, %{warning_count: n}} -> n end))
    }

    handle_total_counts(results, total_counts, fail_on_warnings?)
  end

  @doc false
  def format_to_function_and_pretty_name(format) do
    case format do
      :html -> {&Vnu.validate_html/2, "HTML"}
      :css -> {&Vnu.validate_css/2, "CSS"}
      :svg -> {&Vnu.validate_svg/2, "SVG"}
    end
  end

  defp handle_total_counts(results, total_counts, fail_on_warnings?) do
    case total_counts do
      %{error_count: 0, warning_count: 0} ->
        exit_all_valid()

      %{error_count: e, warning_count: 0} when e > 0 ->
        exit_some_invalid(results)

      %{error_count: e, warning_count: w} when e > 0 and w > 0 ->
        exit_some_invalid(results)

      %{error_count: 0, warning_count: w} when w > 0 ->
        if fail_on_warnings? do
          exit_some_invalid(results)
        else
          exit_all_valid()
        end
    end
  end

  @doc false
  def usage_info(format) do
    """
    mix vnu.validate.#{format} [options] file1 [file2, file3...]

    Options:
      --server-url [string]
          The URL of the Checker server. Defaults to `http://localhost:8888`.

      --fail-on-warnings, --no-fail-on-warnings
          Messages of type `:info` and subtype `:warning` will be treated as if they were validation errors.

      --filter [string]
          A module implementing the `Vnu.MessageFilter` behavior that will be used to exclude messages matching the filter from the result.

    Example:
      mix vnu.validate.#{format} --server-url localhost:8888 priv/static/**/*.#{format}
    """
  end

  @spec print_usage_info(atom()) :: no_return()
  defp print_usage_info(format) do
    Mix.shell().info(usage_info(format))
  end

  @spec exit_all_valid() :: no_return()
  defp exit_all_valid() do
    Mix.shell().info(Formatter.with_color("✓ All OK!", Formatter.success_color()))
    do_exit(:ok)
  end

  @spec exit_some_invalid(list()) :: no_return()
  defp exit_some_invalid(results) do
    Mix.shell().info(summary(results))
    do_exit(:error)
  end

  defp do_exit(status) do
    code =
      case status do
        :ok -> 0
        :error -> 1
      end

    exit({:shutdown, code})
  end

  @doc false
  def summary(results) do
    summary =
      results
      |> Enum.map(fn {file, counts} ->
        summary = Formatter.format_counts(counts, exclude_zeros: true)

        summary =
          if summary == "" do
            Formatter.with_color("✓ OK", Formatter.success_color())
          else
            summary
          end

        "  - #{file}: #{summary}"
      end)
      |> Enum.join("\n")

    "Summary:\n" <> summary
  end
end
