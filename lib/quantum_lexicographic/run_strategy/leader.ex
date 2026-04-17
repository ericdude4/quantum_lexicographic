defmodule QuantumLexicographic.RunStrategy.Leader do
  @moduledoc """
  Run job only on the lexicographically first node in the cluster.

  The leader is determined by sorting all cluster nodes and picking the head.
  Only the leader node returns the full node list; all other nodes return an
  empty list so no jobs execute on them.

  ### Mix Configuration

      config :my_app, MyApp.Scheduler,
        jobs: [
          # Run on leader node only (which then dispatches to all cluster nodes)
          [schedule: "* * * * *", run_strategy: QuantumLexicographic.RunStrategy.Leader]
        ]
  """

  @typedoc false
  @type t :: %__MODULE__{}

  defstruct []

  @behaviour Quantum.RunStrategy

  alias Quantum.Job

  @impl Quantum.RunStrategy
  @spec normalize_config!(any) :: t
  def normalize_config!(_), do: %__MODULE__{}

  defimpl Quantum.RunStrategy.NodeList do
    @spec nodes(QuantumLexicographic.RunStrategy.Leader.t(), Job.t()) :: [Node.t()]
    def nodes(_, _) do
      all_nodes = [node() | Node.list()]

      if node() == all_nodes |> Enum.sort() |> hd() do
        all_nodes
      else
        []
      end
    end
  end
end
