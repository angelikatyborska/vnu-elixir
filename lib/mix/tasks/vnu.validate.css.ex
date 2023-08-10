defmodule Mix.Tasks.Vnu.Validate.Css do
  use Mix.Task
  alias Vnu.CLI

  @shortdoc "Validates CSS files"
  @moduledoc """
  Validates CSS files.

  It expects a file or a list of files as an argument.

  ```bash
    mix vnu.validate.css [OPTIONS] FILE [FILE2 FILE3...]
  ```

  See `mix vnu.validate.html` for the list of options and other details.

  Examples
  ```bash
  mix vnu.validate.css screen.css print.css
  mix vnu.validate.css --server-url http://localhost:8888 priv/static/**/*.css
  ```
  """

  @doc false
  @spec run(list()) :: no_return()
  def run(argv) do
    CLI.validate(argv, :css)
  end
end
