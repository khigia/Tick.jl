

# Node in calculation graph
struct Node{T}
    # TODO maybe could have a name (for debug)
    nid
end

eltype(n::Node{T}) where {T} = T

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

function make_node!(d::Dag, t::Type)
    make_node!(d, t, [])
end

function make_node!(d::Dag, t::Type, parents)
    nid = d.nid[] += 1
    n = Node{t}(nid)
    d.nodes[nid] = n
    # all fn must have same type Nullable{t}
    for (pnode, fn) in parents
        _link!(d, pnode.nid, nid, fn)
    end
    n
end
