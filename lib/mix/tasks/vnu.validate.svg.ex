defmodule Mix.Tasks.Vnu.Validate.Svg do
  use Mix.Task
  alias Vnu.CLI

  @shortdoc "Validates SVG files"
  @moduledoc """
  Validates SVG files.

  See `Mix.Tasks.Vnu.Validate.Html` for the list of options and other details.

  Examples

  ```bash
  mix vnu.validate.svg home_icon.svg logo.svg
  mix vnu.validate.svg --server-url localhost:8888 priv/static/**/*.svg
  ```
  """

  @doc false
  @spec run(list()) :: no_return()
  def run(argv) do
    CLI.validate(argv, :svg)
  end
end
