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
        "coveralls.html": :test,
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:excoveralls, "~> 0.18", only: :test}
    ]
  end

  defp aliases do
    [
      lint: ["format"],
      test: ["test --cover"]
    ]
  end
end
