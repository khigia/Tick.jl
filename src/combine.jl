import Base.getindex


## Implement some edge buffering/connector

# TODO how to declare/document interface?

struct Latest
    state
end

push!(aggr::Latest, v) = aggr.state[] = v

generate(aggr::Latest) = aggr.state[]

# TODO `generate` could imply `reset` (one interface only)
reset!(aggr::Latest) = nothing

"""
    latest create a connector that always return last seen value.
"""
latest(st) = Latest(Ref(st))



## Implement combination of node values

# TODO can probably be replaced by NamedTuple
"""
    BVal

Value created by a Builder (combining multiple node into Tuple)
"""
struct BVal{T <: Tuple}
    fields
    val::T
end

eltype(::Type{BVal{T}}) where {T} = T

function getindex(bval::BVal, i::String)
    bval.val[bval.fields[i]]
end
function getindex(bval::BVal, i)
    bval.val[i]
end


# NTicker: ref to a node inside the Graph (reducer, triggering, name)
struct NTicker
    name
    node
    buf
    triggering
end

"""
    Builder combine multiple node inputs into one output.

Internal component used by `combine`.
"""
struct Builder
    fields
    bufs
    triggering
end

function Builder(nticks)
    # names must be unique
    @assert length(Set([ntkr.name for ntkr in nticks])) == length(nticks)
    # one edge must be triggering
    @assert any([ntkr.triggering for ntkr in nticks])

    Builder(
        Dict(ntkr.name => i for (i, ntkr) in enumerate(nticks)),
        [ntkr.buf for ntkr in nticks],
        [ntkr.triggering for ntkr in nticks],
    )
end

function push!(b::Builder, i, v)
    push!(b.bufs[i], v)
    return b.triggering[i]
end

function generate(b::Builder)  # TODO Nullable
    # TODO even if triggering, maybe can ask each aggregator if
    #      they are ready (maybe some don't want the universe to be
    #      created if they have no value)
    BVal(
        b.fields,  # dict are mutable, pass by ref
        Tuple(generate.(b.bufs)),
    )
end

reset!(b::Builder) = reset!.(b.bufs)

function feed(b::Builder, i, v)
    trig = push!(b, i, v)
    if trig
        # TODO generate could still fail (e.g. missing required input)
        bv = generate(b)
        reset!(b)
        return Nullable(bv)
    else
        return Nullable()
    end
end

# TODO multiple combine version could handle other type than BVal, e.g. Array
#      or even splatting small number of parent values
function combine!(d::Dag, parents)
    # TODO NTicker is not needed ... but parents could benefit type for doc
    uticks = map(t->NTicker(t...), parents)
    builder = Builder(uticks)

    TX = map(ut->eltype(ut.node), uticks)
    OT = BVal{Tuple{TX...}}

    bparents = [
        (ntkr.node, v -> feed(builder, i, v))
        for (i, ntkr) in enumerate(uticks)
    ]

    return node!(d::Dag, OT, bparents)
end

# combine assuming Latest/init and apply a function to all parts
function apply!(d::Dag, fun, init, nodes...)
    CT = mapreduce(eltype, promote_type, nodes)
    bufs = [latest(init) for n in nodes]
    return node!(d, CT, [
        (n, v -> begin
            push!(bufs[i], v)
            Nullable(fun(map(generate, bufs)))
        end)
        for (i, n) in enumerate(nodes)
    ])
end


"""
    tr!(d::Dag, parent::Node, fun::Function)

Create a new node transforming any parent input through `fn`.
"""
function tr!(d::Dag, parent, fn)
    NT = return_type_fn1(fn, eltype(parent))
    node!(d, NT, [(parent, x->Nullable(fn(x)))])
end
