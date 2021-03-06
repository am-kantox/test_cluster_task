defmodule DistributedEnv do
  @moduledoc false

  # The code is based on the `distributed_test` by Sam Schneider (credits!)

  use GenServer

  @timeout 30_000

  @primary_num 0
  @primary "_#{@primary_num}"
  @slave "_"
  @host "127.0.0.1"

  def start_link(count, app \\ nil),
    do: GenServer.start_link(__MODULE__, [count: count, app: app], name: __MODULE__)

  def stop, do: GenServer.stop(__MODULE__)

  def init(count: count, app: app) do
    spawn_master(app)
    spawn_slaves(count, app)
    # FIXME
    {:ok, app}
  end

  def terminate(_reason, _state) do
    Enum.each(Node.list(), &:slave.stop/1)
    :net_kernel.stop()
  end

  ##############################################################################

  defp spawn_master(app) do
    :net_kernel.start([:"#{app}#{@primary}@#{@host}"])
    :erl_boot_server.start([])
    allow_boot(~c"#{@host}")
  end

  defp spawn_slaves(count, app) do
    (@primary_num + 1)..count
    |> Stream.map(fn index -> ~c"#{app}#{@slave}#{index}@#{@host}" end)
    |> Stream.map(&Task.async(fn -> spawn_slave(&1, app) end))
    |> Stream.map(&Task.await(&1, @timeout))
    |> Enum.to_list()
  end

  defp spawn_slave(node_host, app) do
    with {:ok, node} <- :slave.start(~c"#{@host}", node_name(node_host), inet_loader_args()) do
      add_code_paths(node)
      transfer_configuration(node, app)
      ensure_applications_started(node, app)
      {:ok, node}
    end
  end

  defp rpc(node, module, function, args),
    do: :rpc.block_call(node, module, function, args)

  defp inet_loader_args,
    do: ~c"-loader inet -hosts #{@host} -setcookie #{:erlang.get_cookie()}"

  defp allow_boot(host) do
    with {:ok, ipv4} <- :inet.parse_ipv4_address(host),
         do: :erl_boot_server.add_slave(ipv4)
  end

  defp add_code_paths(node),
    do: rpc(node, :code, :add_paths, [:code.get_path()])

  defp transfer_configuration(node, app) do
    for {app_name, _, _} <- [{app, nil, nil} | Application.loaded_applications()] do
      for {key, val} <- Application.get_all_env(app_name) do
        rpc(node, Application, :put_env, [app_name, key, val])
      end
    end
  end

  defp ensure_applications_started(node, _app) do
    rpc(node, Application, :ensure_all_started, [:mix])
    rpc(node, Mix, :env, [Mix.env()])

    for {app_name, _, _} <- Application.loaded_applications() do
      rpc(node, Application, :ensure_all_started, [app_name])
    end
  end

  defp node_name(node_host) do
    node_host
    |> to_string()
    |> String.split("@")
    |> Enum.at(0)
    |> String.to_atom()
  end
end
