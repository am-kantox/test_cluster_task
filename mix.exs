defmodule TestClusterTask.Mixfile do
  use Mix.Project

  @app :test_cluster_task

  def project do
    [
      app: @app,
      version: "0.3.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      preferred_cli_env: [{:"test.cluster", :test}],
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev}]
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
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Aleksei Matiushkin"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/am-kantox/test_cluster_task"}
    ]
  end
end
