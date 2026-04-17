defmodule QuantumLexicographic.RunStrategy.LeaderTest do
  use ExUnit.Case

  describe "normalize_config!/1" do
    test "accepts nil" do
      assert %QuantumLexicographic.RunStrategy.Leader{} =
               QuantumLexicographic.RunStrategy.Leader.normalize_config!(nil)
    end

    test "accepts a keyword list" do
      assert %QuantumLexicographic.RunStrategy.Leader{} =
               QuantumLexicographic.RunStrategy.Leader.normalize_config!(foo: :bar)
    end

    test "accepts a map" do
      assert %QuantumLexicographic.RunStrategy.Leader{} =
               QuantumLexicographic.RunStrategy.Leader.normalize_config!(%{})
    end

    test "accepts any term" do
      assert %QuantumLexicographic.RunStrategy.Leader{} =
               QuantumLexicographic.RunStrategy.Leader.normalize_config!("random string")
    end

    test "returns a struct with no fields" do
      result = QuantumLexicographic.RunStrategy.Leader.normalize_config!(nil)
      assert %QuantumLexicographic.RunStrategy.Leader{} = result
      assert Map.keys(result) == [:__struct__]
    end
  end

  describe "nodes/2 in single-node mode" do
    test "returns the current node as leader when no other nodes are connected" do
      # In test mode, node() is :"nonode@nohost" and Node.list() returns [],
      # so this node is always the lexicographic leader
      strategy = %QuantumLexicographic.RunStrategy.Leader{}

      job = %Quantum.Job{
        name: :test_job,
        run_strategy: %Quantum.RunStrategy.Local{},
        overlap: false,
        timezone: :utc
      }

      assert Quantum.RunStrategy.NodeList.nodes(strategy, job) == [node()]
    end
  end
end
