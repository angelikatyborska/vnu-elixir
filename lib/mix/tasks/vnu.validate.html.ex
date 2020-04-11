defmodule Mix.Tasks.Vnu.Validate.Html do
  use Mix.Task
  alias Vnu.CLI

  @shortdoc "Validate HTML files"
  @moduledoc @shortdoc

  @doc false
  @spec run(list()) :: no_return()
  def run(argv) do
    CLI.validate(argv, :html)
  end
end
