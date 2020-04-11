defmodule Vnu.MixProject do
  use Mix.Project

  def project do
    [
      app: :vnu,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      docs: [extras: ["README.md"]],
      dialyzer: [plt_add_apps: [:mix, :ex_unit]],
      source_url: "https://github.com/angelikatyborska/vnu-elixir/"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["test/support" | elixirc_paths(:any)]
  defp elixirc_paths(_), do: ["lib", "test/fixtures"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.2"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.21", only: [:dev], runtime: false},
      {:bypass, "~> 1.0", only: [:test]}
    ]
  end

  defp aliases() do
    [
      lint: ["compile --force --warnings-as-errors", "format", "credo", "dialyzer"]
    ]
  end
end
