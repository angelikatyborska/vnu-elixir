defmodule Mix.Tasks.Vnu.Validate.Css do
  use Mix.Task
  alias Vnu.CLI

  @shortdoc "Validate CSS files"
  @moduledoc @shortdoc

  @doc false
  @spec run(list()) :: no_return()
  def run(argv) do
    CLI.validate(argv, :css)
  end
end
