defmodule Mix.Tasks.Vnu.Validate.Svg do
  use Mix.Task
  alias Vnu.CLI

  @shortdoc "Validates SVG files"
  @moduledoc """
  Validates SVG files.

  It expects a file or a list of files as an argument.

  ```bash
    mix vnu.validate.svg [OPTIONS] FILE [FILE2 FILE3...]
  ```

  See `mix vnu.validate.html` for the list of options and other details.

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
