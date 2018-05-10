
# TODO can probably replace by NamedTuple
# TODO at least need to keep type info
struct BVal
    fields
    val
end

import Base.getindex
function getindex(bval::BVal, i::String)
    bval.val[bval.fields[i]]
end
function getindex(bval::BVal, i)
    bval.val[i]
end


# NTicker: ref to a node inside the Graph (reducer, triggering, name)
struct NTicker
    name
    ticker_node
    edgebuf
    triggering
end


struct Builder
    nticks
    fields
    bufs
end

function make_builder(nticks)
    # TODO ticks names must be unique
    # TODO MUST have one triggering!
    Builder(
        nticks,
        Dict(ntkr.name => i for (i, ntkr) in enumerate(nticks)),
        [ntkr.edgebuf for ntkr in nticks],
    )
end

function add(b::Builder, i, v)  # TODO push!
    return add(b.bufs[i], v) && b.nticks[i].triggering
end

function generate(b::Builder)  # TODO Nullable{BVal}
    # TODO even if triggering, maybe can ask each aggregator if
    #      they are ready (maybe some don't want the universe to be
    #      created if they have no value)
    BVal(  # TODO NamedTuple
        b.fields,  # dict are mutable, pass by ref
        [generate(buf) for buf in b.bufs],
    )
end

function reset(b::Builder)
    reset.(b.bufs)  # broadcast ~ map
end

function feed(b::Builder, i, v)
    trig = add(b, i, v)
    if trig
        # TODO generate could still fail (e.g. missing required input)
        bv = generate(b)
        reset(b)
        return Nullable(bv)
    else
        return Nullable()
    end
end

# TODO multiple combine version could return Tuple, or BVal etc
# TODO specialized version can just combine 2 node, with Latest semantic
# TODO can keep type info
function combine!(d::Dag, parents)
    # TODO NTicker is not needed!
    uticks = map(t->NTicker(t...), parents)
    builder = make_builder(uticks)

    bparents = [
        (ntkr.ticker_node, v -> feed(builder, i, v))
        for (i, ntkr) in enumerate(uticks)
    ]

    # TODO BVal loose the type kind of
    return node!(d::Dag, BVal, bparents)
end
