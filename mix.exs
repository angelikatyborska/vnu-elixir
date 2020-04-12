defmodule Vnu.MixProject do
  use Mix.Project

  def project do
    [
      app: :vnu,
      version: "1.0.0-rc.1",
      elixir: "~> 1.8",
      lockfile: lockfile(),
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      docs: [extras: ["README.md", "CHANGELOG.md"]],
      dialyzer: [plt_add_apps: [:mix, :ex_unit]],
      description: description(),
      package: package(),
      name: "Vnu",
      source_url: "https://github.com/angelikatyborska/vnu-elixir/",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.circle": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp lockfile() do
    if !!System.get_env("WITH_OLDER_DEPS") do
      "mix-older-deps.lock"
    else
      "mix.lock"
    end
  end

  defp elixirc_paths(:test), do: ["test/support" | elixirc_paths(:any)]
  defp elixirc_paths(_), do: ["lib", "test/fixtures"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:jason, "~> 1.0"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.21", only: [:dev], runtime: false},
      {:bypass, "~> 1.0", only: [:test]},
      {:excoveralls, "~> 0.12", only: [:test]}
    ]
  end

  defp description() do
    "An Elixir client for the Nu HTML Checker (validator.w3.org/nu). Offers validating HTML, CSS, and SVG documents."
  end

  defp package() do
    [
      name: "vnu",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/angelikatyborska/vnu-elixir",
        "Changelog" => "https://github.com/angelikatyborska/vnu-elixir/blob/master/CHANGELOG.md"
      }
    ]
  end

  defp aliases() do
    [
      lint: ["compile --force --warnings-as-errors", "format", "credo", "dialyzer"]
    ]
  end
end
