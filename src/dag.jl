"""
    Node{T}

Computation node with output of type `T`.

Should always be constructed indirectly through `node!`(@ref) or combinator.
"""
struct Node{T}
    # TODO maybe could have a name (for debug)
    nid
end

"""
    eltype(n::Node{T})

Return type `T`.
"""
eltype(n::Node{T}) where {T} = T


"""
    Dag

Directed Acyclic Graph of [`Node{T}`](@ref).
"""
struct Dag
    nid::Ref{Int}  # node id generator (start at 1)
    nodes # nid => Node
    links  # nid => [(nid,fn)]

    Dag() = new(Ref(0), Dict(), Dict())
end

function _link!(d::Dag, src_nid, dst_nid, fn)
    push!(get!(d.links, src_nid, []), (dst_nid, fn))
end

"""
    onfire!(dag, src_nid, fn)

Register a callback `fn` called when new value for node `src_nid` is fired
during evaluation.
"""
function onfire!(d::Dag, src_nid, fn)
    _link!(d, src_nid, 0, fn)
end


"""
    node!(d::Dag, t::Type)

Add new node `Node{t}` to the graph.

The node is given a identifier `nid`.
"""
function node!(d::Dag, t::Type)
    node!(d, t, [])
end

"""
    node!(d::Dag, t::Type, parents)

When given `parents`, create edge from parents to created node.

The `parents` is a sequence of pair of node identifier and function; function
should expect the parent node output type and return `Nullable{t}`.
"""
function node!(d::Dag, t::Type, parents)
    nid = d.nid[] += 1
    n = Node{t}(nid)
    d.nodes[nid] = n
    # all fn must have same type Nullable{t}
    for (pnode, fn) in parents
        _link!(d, pnode.nid, nid, fn)
    end
    n
end

# TODO node! when given single parent and single function (transformer node)
