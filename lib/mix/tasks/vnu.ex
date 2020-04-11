defmodule Mix.Tasks.Vnu do
  use Mix.Task

  @shortdoc "Prints Vnu tasks and their information."
  @moduledoc false

  @doc false
  @spec run(list()) :: no_return()
  def run(argv) do
    {_opts, args} = OptionParser.parse!(argv, strict: [])

    case args do
      [] -> general()
      _ -> Mix.raise("Invalid arguments, expected: mix vnu")
    end
  end

  defp general() do
    Application.ensure_all_started(:vnu)
    Mix.shell().info("Vnu v#{Keyword.get(Application.spec(:vnu), :vsn)}")

    Mix.shell().info(
      "An Elixir client for the Nu HTML Checker (v.Nu) (https://validator.w3.org/nu/)."
    )

    Mix.shell().info("\nAvailable tasks:\n")
    Mix.Tasks.Help.run(["--search", "vnu."])
  end
end
