
TODO
- Doc
  - have a README
  - `Documenter.jl` for API and global doc
  - Tutorial (maybe notebook)
- Feature
  - remove Ticker, have only Node (Rx), and provide `combine` function to
    replace `universe` (see comment in dag `make_node!`)
  - validity: ok, paused, invalid (error propagation)
  - Evaluation strategies
    - simple DFS flow
      - check TODO in code, interface changes needed for ticker/buffer
    - topological order: can introduce some parallelism
    - synchronization on external event source id is harder
    - probably need to introduce SimpleTraits to know if graph is static;
      also note that different distribution schemes may not allow strict
      topological evaluation
  - dynamic list of inputs? (e.g. average, add, etc)
  - node that create node? (react on inputs to create new node during `tick`)
  - batching behaviour: ticker can declare if it support batching or not, in
    which case inputs looks like a dataframe
  - distribution scheme: can some nodes be remote? (dagger like)
  - Factory for Ticker (e.g. `Add(Sq(Sin(Root(X))),Sq(Cos(Root(Y))))` should
    translate in all nodes/tickers creation. Need to define a (recursive) Ticker
    representation in the line of type name and argument configuration.
- Julia
  - Better test / run
  - Package
- Implementation design
  - Maybe: add typing to ticker inputs (make_node! already has info:edgebuf_factory)
  - Builder value / ticker inputs looks like a row of dataframe (see batching)
  - Using a LightGraphs might looks heavy for the task, but ...
    - expose concepts (make obvious node and edge)
    - plotting the graph
    - compute topological sort (e.g. using dfs)
    - note that LightGraphs does funny things when removing vertex!
