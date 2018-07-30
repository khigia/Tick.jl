function add!(d::Dag, parents)  # TODO rename sum!
    # TODO parents is similar to `combine!` ... need a type info for doc
    cn = combine!(d, parents)

    # combine! return a BVal{Tuple{...}}
    # the retuned node type after add! is promote_type of all types in tuple
    CT = promote_type(eltype(eltype(cn)).parameters...)  # TODO method of BVal
    @assert promote_type(map(p -> eltype(p[2]), parents)...) == CT

    return node!(d, CT, [(cn, v -> Nullable(sum(v.val)))])
end

# TODO doc; similar to combining version, but all nodes always trigger and
#      always use Latest value of previous nodes
function add!(d::Dag, nodes...)
    return apply!(d, sum, 0, nodes...)
end


function first!(d::Dag, node::Node{T}) where {T<:Tuple}
    nth!(d, node, 1)
end

function last!(d::Dag, node::Node{T}) where {T<:Tuple}
    # Cannot call nth! directly as below
    # because `end` is not recognize as last elt index
    # nth!(d, node, end)
    nth!(d, node, length(eltype(node).types))
end

function nth!(d::Dag, node::Node{T}, n) where {T<:Tuple}
    EE = eltype(node).types[n]
    node!(d, EE, [(node, v -> Nullable(v[n]))])
end


# create a moving window node, i.e. transform input in vector of last N values
# TODO maybe have a diff output: instead of vector could also output what's
#      added and what's removed (for online stream calculation) ... maybe a
#      diff win! interface can do that
function win!(d::Dag, node::Node, n)
    EE = Vector{eltype(node)}
    # TODO Datastructures.jl CircularDeque
    vec = EE()

    function win_push!(v)
        while length(vec) >= n
            shift!(vec)
        end
        push!(vec, v)
    end

    # node!(d, EE, [(node, v -> Nullable(win_push!(v)))])
    tr!(d, node, win_push!)
end
