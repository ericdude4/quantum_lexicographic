# QuantumLexicographic

A [Quantum](https://hexdocs.pm/quantum) run strategy that executes each
scheduled job on exactly **one** node of a distributed Erlang cluster: the node
whose name sorts first lexicographically.

Every node's scheduler evaluates the strategy independently. The leader returns
`[node()]` and dispatches the job to itself; every other node returns `[]` and
dispatches nothing. No coordination or locking is needed as long as every node
sees the same cluster membership.

## Installation

```elixir
def deps do
  [
    {:quantum_lexicographic, git: "git@github.com:ericdude4/quantum_lexicographic.git"}
  ]
end
```

## Usage

```elixir
config :my_app, MyApp.Scheduler,
  jobs: [
    [schedule: "* * * * *", task: {MyApp, :work, []}, run_strategy: QuantumLexicographic.RunStrategy.Leader]
  ]
```

Or when building jobs at runtime:

```elixir
MyApp.Scheduler.new_job(
  name: :work,
  schedule: ~e[* * * * *],
  run_strategy: %QuantumLexicographic.RunStrategy.Leader{},
  task: {MyApp, :work, []}
)
```

`QuantumLexicographic.RunStrategy.Leader.leader?/0` reports whether the
current node is the leader, which is handy for logging or health checks.

## Caveat

Leadership is derived from `[node() | Node.list()]`. A node that is not
connected to the rest of the cluster sees only itself and will act as leader,
so verify that clustering (e.g. libcluster) is actually up.
