defmodule QuantumLexicographic.RunStrategy.LeaderTest do
  use ExUnit.Case

  alias QuantumLexicographic.RunStrategy.Leader

  describe "normalize_config!/1" do
    test "accepts nil" do
      assert %Leader{} = Leader.normalize_config!(nil)
    end

    test "accepts a keyword list" do
      assert %Leader{} = Leader.normalize_config!(foo: :bar)
    end

    test "accepts a map" do
      assert %Leader{} = Leader.normalize_config!(%{})
    end

    test "accepts any term" do
      assert %Leader{} = Leader.normalize_config!("random string")
    end

    test "returns a struct with no fields" do
      result = Leader.normalize_config!(nil)
      assert %Leader{} = result
      assert Map.keys(result) == [:__struct__]
    end
  end

  describe "leader/0 and leader?/0" do
    test "the only node in a cluster of one is the leader" do
      assert Leader.leader() == node()
      assert Leader.leader?()
    end
  end

  describe "nodes/2" do
    test "returns only the current node when it is the leader" do
      # In test mode, node() is :"nonode@nohost" and Node.list() returns [],
      # so this node is always the lexicographic leader. The strategy must
      # return exactly one node — never the whole cluster — so that Quantum
      # executes the job on a single node.
      job = %Quantum.Job{
        name: :test_job,
        run_strategy: %Leader{},
        overlap: false,
        timezone: :utc
      }

      assert Quantum.RunStrategy.NodeList.nodes(%Leader{}, job) == [node()]
    end
  end
end
