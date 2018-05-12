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
