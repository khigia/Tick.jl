# NTicker: ref to a Ticker inside the Graph (reducer, triggering, name)
struct NTicker  # TODO rename to NodeRef? Edge?
    name
    ticker_node
    edgebuf_factory  # TODO type!
    triggering
end



# Node in calculation graph
struct Node{T}
    # TODO maybe could have a name (for debug)
    nid
    ticker::Ticker{T}
    builder
end


struct Dag
    nid::Ref{Int}  # node id generator (start at 1)
    nodes # nid => Node
    links  # nid => [(nid,fn)]

    Dag() = new(Ref(0), Dict(), Dict())
end

function _link!(d::Dag, src_nid, dst_nid, fn)
    push!(get!(d.links, src_nid, []), (dst_nid, fn))
end

function onfire!(d::Dag, src_nid, fn)
    _link!(d, src_nid, 0, fn)
end

function make_node!(d::Dag, ticker::RootTicker)
    make_node!(d, ticker, [])
end

# TODO instead of one ticker and a list of nodes (universe), can probably have
#      a list of pair <node, callback>
#      the callback make the `tick` interface more generic, and the need for
#      universe is replaced by the possibility to create a node using
#      `combine` which does all the builder thingy if needed ... but note that
#      this combined node is kind of unique (sharing semantic can be complexe).
#      This make Ticker for simple thing like `add` easy to implement, while
#      keeping more advance Ticker possibility (Ticker interface is not needed).
function make_node!(d::Dag, ticker, bufs)
    nid = d.nid[] += 1
    uticks = [
        NTicker(u..., b...)
        for (u, b) in zip(universe(ticker), bufs)
    ]
    builder = make_builder(uticks)
    n = Node(nid, ticker, builder)

    d.nodes[nid] = n

    for (i, ntkr) in enumerate(uticks)
        src = ntkr.ticker_node
        _link!(d, src.nid, nid, v -> add(builder, i, v))
    end

    n
end
