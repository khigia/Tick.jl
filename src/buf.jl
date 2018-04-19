
# TODO can probably replace by NamedTuple
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


struct Builder
    nticks
    fields
    bufs  # TODO Vector{Combiner}
end

function make_builder(nticks)
    # TODO ticks names must be unique
    # TODO MUST have one triggering!
    Builder(
        nticks,
        Dict(ntkr.name => i for (i, ntkr) in enumerate(nticks)),
        [ntkr.edgebuf_factory() for ntkr in nticks],
    )
end

function add(b::Builder, i, v)
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



# TODO Fisrt, Collect, Reducer(fn) ... maybe no need for add/generate/reset, reduce/init is better

struct Latest
    v
    Latest(x) = new(Ref(x))
end

function add(aggr::Latest, v)
    aggr.v[] = v
    true  # trigger
end

generate(aggr::Latest) = aggr.v[]

reset(aggr::Latest) = nothing  # always keep latest
