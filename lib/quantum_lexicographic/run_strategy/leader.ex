defmodule QuantumLexicographic.RunStrategy.Leader do
  @moduledoc """
  Run a job on exactly one node in the cluster: the lexicographically first
  node name among `[node() | Node.list()]`.

  Quantum's `Quantum.RunStrategy.NodeList` protocol is asked, on **every** node's
  scheduler, which nodes a job should be dispatched to. Quantum then executes
  the task on each node returned. So to get single-node execution the leader
  must return only *itself*, and every other node must return `[]`.

  Because leadership is derived purely from the sorted node list, all nodes
  agree on the same leader without any coordination, provided they see the same
  cluster membership. If a node is not connected to the rest of the cluster
  (`Node.list() == []`) it will consider itself the leader, so make sure
  distributed Erlang clustering is actually working.

  ### Mix Configuration

      config :my_app, MyApp.Scheduler,
        jobs: [
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

  @doc """
  Returns the leader node for the current cluster membership.
  """
  @spec leader() :: Node.t()
  def leader, do: Enum.min([node() | Node.list()])

  @doc """
  Whether the current node is the cluster leader.
  """
  @spec leader?() :: boolean()
  def leader?, do: leader() == node()

  defimpl Quantum.RunStrategy.NodeList do
    alias QuantumLexicographic.RunStrategy.Leader

    @spec nodes(Leader.t(), Job.t()) :: [Node.t()]
    def nodes(_, _) do
      if Leader.leader?(), do: [node()], else: []
    end
  end
end
