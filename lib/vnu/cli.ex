defmodule Vnu.CLI do
  @moduledoc false

  alias Vnu.Formatter

  @doc false
  @spec validate(list(), atom()) :: no_return()
  def validate(argv, format) do
    {opts, files, invalid_args} =
      OptionParser.parse(argv,
        strict: [
          http_client: :string,
          server_url: :string,
          fail_on_warnings: :boolean,
          filter: :string
        ]
      )

    if invalid_args != [] do
      print_usage_info(format)
      Mix.raise("Invalid options: #{inspect(invalid_args)}")
    end

    if files == [] do
      print_usage_info(format)
      Mix.raise("No files given")
    end

    opts =
      if Keyword.get(opts, :http_client) do
        Keyword.update!(opts, :http_client, &Module.concat([&1]))
      else
        opts
      end

    opts =
      if Keyword.get(opts, :filter) do
        Keyword.update!(opts, :filter, &Module.concat([&1]))
      else
        opts
      end

    if Keyword.get(opts, :filter) || Keyword.get(opts, :http_client) do
      # must compile to ensure the filter module is available
      Mix.Task.run("compile", [])
    end

    fail_on_warnings? = Keyword.get(opts, :fail_on_warnings, false)

    {validate_function, pretty_name} = format_to_function_and_pretty_name(format)

    Mix.shell().info("\nValidating #{pretty_name} files:")
    file_list = Enum.map_join(files, "\n", &"  - #{&1}")
    Mix.shell().info(file_list <> "\n")

    Application.ensure_all_started(:hackney)

    results =
      Enum.map(files, fn file ->
        with {:ok, document} <- read_file(file),
             {:ok, result} <- validate_document(file, document, opts, validate_function) do
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
        end
      end)

    total_counts = %{
      error_count: Enum.sum(Enum.map(results, fn {_, %{error_count: n}} -> n end)),
      warning_count: Enum.sum(Enum.map(results, fn {_, %{warning_count: n}} -> n end))
    }

    handle_total_counts(results, total_counts, fail_on_warnings?)
  end

  defp read_file(file) do
    case File.read(file) do
      {:ok, content} ->
        {:ok, content}

      {:error, error} ->
        Mix.raise("File #{file} could not be read:\n  #{inspect(error)}")
    end
  end

  defp validate_document(file, document, opts, validate_function) do
    case validate_function.(document, opts) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        Mix.raise("Could not finish validating #{file}:\n  #{inspect(error)}")
    end
  end

  @doc false
  def format_to_function_and_pretty_name(format) do
    case format do
      :html -> {&Vnu.validate_html/2, "HTML"}
      :css -> {&Vnu.validate_css/2, "CSS"}
      :svg -> {&Vnu.validate_svg/2, "SVG"}
    end
  end

  @spec handle_total_counts(map(), map(), boolean()) :: no_return()
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

  @spec print_usage_info(atom()) :: no_return()
  defp print_usage_info(format) do
    Mix.Tasks.Help.run(["vnu.validate.#{format}"])
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
      |> Enum.map_join("\n", fn {file, counts} ->
        summary = Formatter.format_counts(counts, exclude_zeros: true)

        summary =
          if summary == "" do
            Formatter.with_color("✓ OK", Formatter.success_color())
          else
            summary
          end

        "  - #{file}: #{summary}"
      end)

    "Summary:\n" <> summary
  end
end
