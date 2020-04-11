defmodule Mix.Tasks.Vnu.Validate.Svg do
  use Mix.Task
  alias Vnu.CLI

  @shortdoc "Validate SVG files"
  @moduledoc @shortdoc

  @doc false
  @spec run(list()) :: no_return()
  def run(argv) do
    CLI.validate(argv, :svg)
  end
end
