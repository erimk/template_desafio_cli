defmodule DesafioCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :desafio_cli,
      version: "0.1.0",
      elixir: "~> 1.16",
      escript: [main_module: DesafioCli],
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:excoveralls, "~> 0.18", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:mimic, "~> 1.10", only: :test}
    ]
  end

  defp aliases do
    [
      lint: ["format", "credo --strict"],
      test: ["test --cover"]
    ]
  end
end
