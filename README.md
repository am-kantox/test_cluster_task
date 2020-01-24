# Mix tasks to test and run on several nodes

Run tests in a distributed environment (cluster with several nodes).

The code is based on the
[`distributed_test`](https://github.com/sschneider1207/distributed_test)
by _Sam Schneider_ (credits!)

## Usage

**¡NB!** `empd` must be started to use this functionality.

Use the default number of nodes (1 master + 4 slaves)
```
mix test.cluster
```

Use a specific number of nodes (1 master + n slaves).  Note the master is
not included in the count.
```
mix test.cluster --count 7
```

## Setting up github action for CI

The project that uses `test_cluster_task` should have `epmd` started before running tests. This is a scaffold of how your GH Action might be configured (thanks to https://github.com/actions/setup-elixir)

```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    name: OTP ${{matrix.otp}} / Elixir ${{matrix.elixir}}
    strategy:
      matrix:
        otp: [21.3, 22.2]
        elixir: [1.9.4]
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-elixir@v1
        with:
          otp-version: ${{matrix.otp}}
          elixir-version: ${{matrix.elixir}}
      - run: MIX_ENV=ci epmd -daemon
      - run: MIX_ENV=ci mix deps.get
      - run: MIX_ENV=ci mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `test_cluster_task` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:test_cluster_task, "~> 0.3"}]
end
```

