defmodule Mix.Tasks.Vnu.Validate.Css do
  use Mix.Task
  alias Vnu.CLI

  @shortdoc "Validates CSS files"
  @moduledoc """
  Validates CSS files.

  See `Mix.Tasks.Vnu.Validate.Html` for the list of options and other details.

  Examples
  ```bash
  mix vnu.validate.css screen.css print.css
  mix vnu.validate.css --server-url localhost:8888 priv/static/**/*.css
  ```
  """

  @doc false
  @spec run(list()) :: no_return()
  def run(argv) do
    CLI.validate(argv, :css)
  end
end
