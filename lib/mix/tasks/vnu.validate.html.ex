defmodule Mix.Tasks.Vnu.Validate.Html do
  use Mix.Task
  alias Vnu.CLI

  @shortdoc "Validates HTML files"
  @moduledoc """
  Validates HTML files.

  Options

  - `--server-url` - The URL of [the Checker server](https://github.com/validator/validator). Defaults to `http://localhost:8888`.
  - `--fail-on-warnings` -  Messages of type `:info` and subtype `:warning` will be treated as if they were validation errors.
    Their presence will mean the document is invalid. Defaults to `false`.
  - `--filter` - A module implementing the `Vnu.MessageFilter` behavior that will be used to exclude messages matching the filter from the result.
    Defaults to `nil` (no excluded messages).

  Examples

  ```bash
  mix vnu.validate.html index.html about.html
  mix vnu.validate.html --server-url localhost:8888 priv/static/**/*.html
  mix vnu.validate.html --filter MyApp.VnuMessageFilter priv/static/**/*.html
  ```
  """

  @doc false
  @spec run(list()) :: no_return()
  def run(argv) do
    CLI.validate(argv, :html)
  end
end
