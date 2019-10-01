defmodule Mix.Tasks.Run.Cluster do
  @moduledoc """
  Run a project in a distributed environment.

  This mix task starts up a cluster of nodes before running the `Mix.Tasks.Run`
  mix task. The number of nodes to start (besides the master node) can be set
  using the "-count #" switch (defaults to 4). Each slave node will have the code
  and application environment from the master node loaded onto it.  All switches
  for the `mix run` task will be passed along to it.
  """
  use Mix.Task

  @shortdoc "Runs a project in a distributed environment"
  @recursive true

  @default_count 4

  def run(params) do
    app = Mix.Project.config()[:app]

    {switches, _, _} = OptionParser.parse(params, switches: [count: :integer])

    params =
      if Keyword.has_key?(switches, :count),
        do: remove_param(params, "count"),
        else: params

    Mix.Tasks.Run.run(["--no-start" | params])

    switches
    |> Keyword.get(:count, @default_count)
    |> DistributedEnv.start_link(app)

    config_path = Mix.Project.config()[:config_path]
    :rpc.multicall(Node.list(), Mix.Tasks.Run.Distributed, :load_config, [config_path])

    :rpc.eval_everywhere(Application, :ensure_all_started, [app])
  end

  def load_config(path) do
    for {app, config} <- Mix.Config.read!(path),
        do: Enum.each(config, fn {k, v} -> Application.put_env(app, k, v) end)
  end

  defp remove_param(params, name, acc \\ [])
  defp remove_param([], _name, acc), do: :lists.reverse(acc)
  defp remove_param(["--" <> name | [_num | rem]], name, acc), do: :lists.reverse(acc) ++ rem
  defp remove_param([head | rem], name, acc), do: remove_param(rem, name, [head | acc])
end
