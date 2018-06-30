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
    E1 = eltype(node).types[1]
    node!(d, E1, [(node, v -> Nullable(first(v)))])
end

function last!(d::Dag, node::Node{T}) where {T<:Tuple}
    EE = eltype(node).types[end]
    node!(d, EE, [(node, v -> Nullable(last(v)))])
end

# TODO nth!

# create a moving window node, i.e. transform input in vector of last N values
# TODO maybe remove the fn (can be a separate node)
# TODO maybe have a diff output: instead of vector could also output what's
#      added and what's removed (for online stream calculation) ... maybe a
#      diff win! interface can do that
function win!(d::Dag, node::Node, n, fn=identity)
    EE = Vector{eltype(node)}
    # TODO Datastructures.jl CircularDeque
    vec = EE()

    NT = return_type_fn1(fn, EE)

    function win_push!(vec, n, v)
        while length(vec) >= n
            shift!(vec)
        end
        push!(vec, v)
    end
    node!(d, NT, [(node, v -> Nullable(win_push!(vec, n, v) |> fn))])
end
