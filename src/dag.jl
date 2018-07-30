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
    nodes # nid => Node  # TODO array instead of Dict

    # TODO current typing is weak ... could remove ... or could replace the
    #      link function with Connector{T} type to make sure Node links would
    #      contain only expected connector type
    #      ... maybe have branch without type, and from there see if we can
    #      build new version to reify connector.
    links  # nid => [(nid,fn)]  # TODO array instead of Dict (or store in Node)

    Dag() = new(Ref(0), Dict(), Dict())
end

function _link!(d::Dag, src_nid, dst_nid, fn)
    # TODO check type fn vs src_nid?
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
should expect one argument of the parent node output type and should return a
value of type `Nullable{t}`. Note that all the functions should return the same
type.
"""
function node!(d::Dag, t::Type, parents)
    nid = d.nid[] += 1
    n = Node{t}(nid)
    d.nodes[nid] = n
    for (pnode, fn) in parents
        # all fn must have same return type Nullable{t}

        # TODO fn type could be checked through undocumented (not recommended)
        #      function `return_types` but this seems to fail for combine!
        # @assert Base.return_types(fn, (eltype(pnode),)) == [Nullable{t}]
        # TODO can we use functor (link below) to ensure fn(eltype(pnode)) isa Nullable{t}
        # # https://discourse.julialang.org/t/enforcing-function-signatures-by-both-argument-return-types/8174
        # struct Functor{T,R} f end
        # function (ff::Functor{T,R})(x::T)::R where {T,R}
        #     R(ff.f(x))  # not sure if R() is needed
        # end
        # this would raise at call time if f is not ok ... probably inefficient.
        # Another approach is to define new type for each callback and not have
        # f as a field by embedding in type method definition
        # TODO or https://github.com/mauro3/SimpleTraits.jl and enforce user
        # to pass a specific type
        # TODO or https://github.com/yuyichao/FunctionWrappers.jl
        # TODO or just removed Node typing altogether?

        _link!(d, pnode.nid, nid, fn)
    end
    n
end

"""
    return_type_fn1(fn, T)

Return type returned by calling fn with one argument of type T.

fn must be type stable, else AssertionError is raised.

Note: guessing type is not recommended:
      https://groups.google.com/forum/#!topic/julia-users/gb_DR5EzmV4
"""
function return_type_fn1(fn, input_type)
    rets = Base.return_types(fn, (input_type,))
    @assert length(rets) == 1
    return first(rets)
end
