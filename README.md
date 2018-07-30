`Tick` is a package that evaluate a graph of computation nodes.

This is an experimental and not finished toy!

Its design originate from financial application where various discrete feed
events are continuously generating derived signal feeds. A simple example is
creating a spread (difference) price signal of the moving average of 2 ticker
price feeds i.e. `spread = ma(P1) - ma(P2)`. This is something that reactive
programming excel at. But even in this contrived example, it is sometimes needed
to declare what happen to `spread` when only `P1` change, or to make sure no
intermediate value of `spread` is computed if both `P1` and `P2` are changed
"simultaneously". In short, it is sometimes useful to describe explicitly how
events can be synchronized in the computation graph.

This package is thus an experiment, using reactive programming concept, but
focusing mainly on declaring nodes relationship with regard to evaluation.
There are some inspirations (not enough!) of some great reactive (or data flow)
libraries like beam`, `Rx`, `Reactive.jl`, or `Rust futures Stream`.

Key aspect of `Tick.jl`
- Focus on universe declaration (`combine!`): a node declare its parents but
  also how values are passed around (e.g. eliding of multiple node activation in
  topologically sorted evaluation cycle). Goal is to make explicit the
  synchronization of node inputs, but leave implementation to the evaluator.
- Mostly static graph and typing is used to manage some coherence at graph
  construction time.
- Evaluation strategy is explicitly kept outside the graph to give control and
  allow experimenting with multiple graphs (possibly hierarchical) as well as
  parallel and remote evaluation.

Note: this implementation is mostly an exercise in learning Julia (no
expectation on performance) as well as a place for prototyping.


## TODO

- grep code for `TODO` ... notably removing type declaration for Node (dag.jl)
- examples testing main features
  - generating bar data (time based firing)
  - spread price with MA (listen to combined data)
  - ... (simultaneous firing)
- possible design change: `Node` could be forced to always have a value (when
  not available user can then use a `Nullable`). This would allow more type
  discovery, and probably would make the whole computation lighter, removing
  need for edge buffer. On the other hand, children node would receive
  `Nullable` value not unpacked, and this would require another mechanism for a
  `Node` to not produce a value.
- Doc: API
- validity or error propagation: ok, paused, invalid
- provide default for `Dag`, `Evaluator` etc to make simple graph easy
- Doc: tutorial (maybe notebook)
- shortcut like `Reactive.jl` `@lift` and node with type `Any`
- Evaluation strategies:
  - fire multiple values/nodes at once
  - pass an evaluation/event id (for logging/tracking)
  - topological order: some parallelism/concurrency could be introduced
  - may want to introduce SimpleTraits to know if graph is static;
    also note that different distribution schemes may not allow strict
    topological evaluation
- dynamic graph (node that create node)
- batching behavior: node can declare if it support batching or not, in
  which case inputs looks like a dataframe
- distribution scheme: can some nodes be remote? (dagger like)
- Factory: graph serialized form to save config in file or in messaging.
- Using a LightGraphs might looks heavy for the task, but ...
  - expose concepts (make obvious node and edge)
  - plotting the graph
  - note that LightGraphs does funny things when removing vertex!
- Julia: better test
- Julia: benchmark (many nodes, many inputs)
- Julia: make it a real Package
