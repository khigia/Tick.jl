# NTicker: ref to a Ticker inside the Graph (reducer, triggering, name)
struct NTicker  # TODO rename to NodeRef? Edge?
    name
    ticker_node
    edgebuf_factory  # TODO type!
    triggering
end

Universe = Vector{NTicker}


# Node in calculation graph
struct Node
    # TODO maybe could have a name (for debug)
    nid
    ticker::Ticker
    builder # TODO RootTicker have empty builder that is never used
end


struct Dag
    # TODO AbstractDag ... diff eval: Simple, Topo

    nid::Ref{Int}  # noder id generator (start at 1)
    nodes # nid => Node
    links  # nid => [(nid,fn)]

    Dag() = new(Ref(0), Dict(), Dict())
end

function link!(d::Dag, src_nid, dst_nid, fn)
    push!(get!(d.links, src_nid, []), (dst_nid, fn))
end

function make_node!(d::Dag, ticker)
    nid = d.nid[] += 1
    uticks = universe(d, ticker)
    builder = make_builder(uticks)
    n = Node(nid, ticker, builder)

    d.nodes[nid] = n

    for (i, ntkr) in enumerate(uticks)
        src = ntkr.ticker_node
        link!(d, src.nid, nid, v -> add(builder, i, v))
    end

    n
end
