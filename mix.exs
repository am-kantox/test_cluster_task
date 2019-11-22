defmodule TestClusterTask.Mixfile do
  use Mix.Project

  @app :test_cluster_task
  @version "0.5.1"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [{:"test.cluster", :test}],
      description: description(),
      package: package(),
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      dialyzer: [
        plt_file: {:no_warn, ".dialyzer/plts/dialyzer.plt"},
        plt_add_apps: [:mix],
        ignore_warnings: ".dialyzer/ignore.exs"
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test, :ci], runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test, :ci]},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end

  defp aliases do
    [
      quality: ["format", "credo --strict", "dialyzer"],
      "quality.ci": [
        "format --check-formatted",
        "credo --strict",
        "dialyzer --halt-exit-status"
      ]
    ]
  end

  defp description do
    """
    Run tests in a distributed environment (cluster with several nodes).

    The code is based on the `distributed_test` by Sam Schneider (credits!)
    """
  end

  defp package do
    [
      name: @app,
      files: ~w|config lib mix.exs README.md|,
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/#{@app}",
      source_url: "https://github.com/am-kantox/#{@app}",
      maintainers: ["Aleksei Matiushkin"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/am-kantox/#{@app}",
        "Docs" => "https://hexdocs.pm/#{@app}"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/#{@app}",
      # logo: "stuff/images/logo.png",
      source_url: "https://github.com/am-kantox/#{@app}",
      # assets: "stuff/images",
      extras: [
        "README.md"
      ],
      groups_for_modules: []
    ]
  end
end
