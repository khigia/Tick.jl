# Tick

`Tick` is a package that evaluate graph of computation nodes.

Focus on universe declaration (`combine!`): a node declare its parents and how
values are passed around.
Mostly static graph (continuous mathematical functions composition).
Evaluation strategy give control and allow multiple graphs (possibly hierarchy)
as well as parallel and remote evaluation.

Inspirations: `dataflow`, `Rx`, `Reactive.jl`, Rust futures Stream

It is similar to `Reactive.jl`, `Rx`, _Rust_ `futures Stream` (Reactive
Programming not restricted to `FRP` in `UI` context). It started as a "toy" to
experiment design and Julia programming.


## TODO

- Doc
  - have a real README
  - Tutorial (maybe notebook)
  - API doc
- Feature
  - `combine!` function need type and could have some shortcut like the
    `Reactive.jl` `@lift`
  - grep code for `TODO`
  - Node could be force to always have a value (when not possible user can then
    use a nullable type) to not enforce Nullable when not needed?
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
  - Builder value / ticker inputs looks like a row of dataframe (see batching)
  - batching behaviour: ticker can declare if it support batching or not, in
    which case inputs looks like a dataframe
  - distribution scheme: can some nodes be remote? (dagger like)
  - Factory for Ticker (e.g. `Add(Sq(Sin(Root(X))),Sq(Cos(Root(Y))))` should
    translate in all nodes/tickers creation. Need to define a (recursive) Ticker
    representation in the line of type name and argument configuration.
  - Using a LightGraphs might looks heavy for the task, but ...
    - expose concepts (make obvious node and edge)
    - plotting the graph
    - compute topological sort (e.g. using dfs)
    - note that LightGraphs does funny things when removing vertex!
- Julia
  - Better test / run
  - Package
