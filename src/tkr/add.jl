# TODO can have diff version, using combine or using 2 nodes directly
function add!(d::Dag, parents)
    # parents is similar to `combine!`
    cn = combine!(d, parents)
    ct = promote_type(map(p -> eltype(p[2]), parents)...)
    return make_node!(d, ct, [(cn, v -> Nullable(sum(v.val)))])
end
