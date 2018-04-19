
TODO
- Implementation design
  - Maybe: add typing to ticker inputs (make_node! already has info)
  - Builder value / ticker inputs looks like a row of dataframe (see batching)
  - Using a LightGraphs might looks heavy for the task, but ...
    - expose concepts (make obvious node and edge)
    - plotting the graph
    - compute topological sort (e.g. using dfs)
    - note that LightGraphs does funny things when removing vertex!
- Feature
  - Different evaluation strategies
    - simple DFS flow
    - topological order: eval once all incidence nodes have been evaluated (or
      when can decide that no more incidence node can be evaluated) ... the idea
      being to trigger after computing all dependencies (and avoid multiple
      trigger in same cycle).
    - synchronization on external event source id is harder
  - dynamic list of inputs? (e.g. average, add, etc)
  - node that create node? (react on inputs to create new node during `tick`)
  - validity: ok, paused, invalid
  - batching behaviour: ticker can declare if it support batching or not, in
    which case inputs looks like a dataframe
  - Factory for Ticker (e.g. `Add(Sq(Sin(Root(X))),Sq(Cos(Root(Y))))` should
    translate in all nodes/tickers creation. Need to define a (recursive) Ticker
    representation in the line of type name and argument configuration.
- Julia
  - Better test / run
  - Package
  - Doc
    - `Documenter.jl` for API and global doc
    - Tutorial (maybe notebook)
