defmodule Mix.Tasks.Test.Cluster do
  @moduledoc """
  Run tests for a distributed application.

  This mix task starts up a cluster of nodes before running the `Mix.Tasks.Test`
  mix task. The number of nodes to start (besides the master node) can be set
  using the "-count #" switch (defaults to 4). Each slave node will have the code
  and application environment from the master node loaded onto it.  All switches
  for the `mix test` task will be passed along to it.
  """
  use Mix.Task

  @shortdoc "Runs a project's tests in a distributed environment"
  @recursive true
  @preferred_cli_env :test

  def run(params) do
    unless System.get_env("MIX_ENV") in ["test", "ci"] || Mix.env() in [:test, :ci] do
      IO.puts(
        "\n⚑ “mix test.cluster” is running in environment “#{Mix.env()}”, but it’d better be run in :test."
      )

      Mix.Tasks.Compile.run([])
    end

    Mix.Tasks.Run.Cluster.run([])
    Process.sleep(1_000)

    Mix.Tasks.Test.run(params)

    DistributedEnv.stop()
  end
end
