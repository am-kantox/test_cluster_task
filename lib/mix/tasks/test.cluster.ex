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

  @default_count 4

  def run(params) do
    unless System.get_env("MIX_ENV") || Mix.env() == :test do
      IO.puts(
        "⚑ “mix test.distributed” is running on environment “#{Mix.env()}”.\n" <>
          "⚐   “mix test.distributed” is to be run on :test.\n" <>
          "⚐   Resetting the environment to :test for you."
      )

      Mix.env(:test)
    end

    {switches, _, _} = OptionParser.parse(params, switches: [count: :integer])

    app = Mix.Project.config()[:app]
    Mix.Tasks.Loadpaths.run([])
    Application.ensure_started(app)

    count = Keyword.get(switches, :count, @default_count)
    DistributedEnv.start_link(count, app)

    params =
      if Keyword.has_key?(switches, :count),
        do: remove_param(params, "count"),
        else: params

    Mix.Tasks.Test.run(params)

    DistributedEnv.stop()
  end

  defp remove_param(params, name, acc \\ [])
  defp remove_param([], _name, acc), do: :lists.reverse(acc)
  defp remove_param(["--" <> name | [_num | rem]], name, acc), do: :lists.reverse(acc) ++ rem
  defp remove_param([head | rem], name, acc), do: remove_param(rem, name, [head | acc])
end
