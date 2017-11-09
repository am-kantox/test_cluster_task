# DistributedTest

Run tests in a distributed environment (cluster with several nodes).

The code is based on the
[`distributed_test`](https://github.com/sschneider1207/distributed_test)
by _Sam Schneider_ (credits!)

## Usage

Use the default number of nodes (1 master + 4 slaves)
```
mix test.cluster
```

Use a specific number of nodes (1 master + n slaves).  Note the master is
not included in the count.
```
mix test.cluster --count 7
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `test_cluster_task` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:test_cluster_task, "~> 0.3"}]
end
```

