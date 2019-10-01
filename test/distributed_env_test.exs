defmodule DistributedEnvTest do
  use ExUnit.Case

  test "nodes are stopped and started at will" do
    count = 4

    DistributedEnv.start_link(count)
    assert length(Node.list()) === count

    DistributedEnv.stop()
    assert length(Node.list()) === 0
  end
end
