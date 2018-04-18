
TODO
- Implementation design
  - separating `make_node!` from `universe(Ticker)` is not obvious;
    on one hand it is nice to have universe close to Ticker definition and close
    to the associated `tick` method definition, but on the other hand we want
    to be able to configure the edge buffers;
    most probably `NTicker` need to be split in 2, having name and node reference
    in Ticker construction, while `make_node!` would accept the edge buffer and
    triggering logic.
    - Maybe: add typing to Tick and Universe
- Ticker concepts
  - validity: ok, paused, invalid
  - batching behaviour: ticker can declare if it support batching or not
- Julia
  - Better test / run
  - Package
  - Doc
    - `Documenter.jl` for API and global doc
    - Tutorial (maybe notebook)
- Different evaluation strategies
  - simple DFS flow
  - topological order: eval once all incidence nodes have been evaluated (or
    when can decide that no more incidence node can be evaluated) ... the idea
    being to trigger after computing all dependencies (and avoid multiple
    trigger in same cycle).
  - synchronization on external event source id is harder
- Factory for Ticker (e.g. `Add(Sq(Sin(Root(X))),Sq(Cos(Root(Y))))` should
  translate in all nodes/tickers creation. Need to define a (recursive) Ticker
  representation in the line of type name and argument configuration.
- Using a LightGraphs might looks heavy for the task, but ...
  - expose concepts (make obvious node and edge)
  - plotting the graph
  - compute topological sort (e.g. using dfs)
  - note that LightGraphs does funny things when removing vertex!
