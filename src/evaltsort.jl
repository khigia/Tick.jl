
function tsort(nvertices, egress)
    # TODO could output list of independent nodes, such that parallel eval of
    # the lists are possible.
    color = zeros(Int, nvertices)
    order = Vector{Int}()
    stack = Vector{Int}()
    for v in 1:nvertices
        color[v] != 0 && continue
        push!(stack, v)
        while !isempty(stack)
            cur = stack[end]
            color[cur] = 1
            for child in egress(cur)
                assert(color[child] != 1)  # cycle (not a DAG)
                color[child] != 0 && continue
                push!(stack, child)
            end
            if cur == stack[end]
                color[cur] = 2
                push!(order, cur)
                pop!(stack)
            end
        end
    end
    reverse(order)
end


struct EvalTSort end
# TODO maybe pass Dag, assume static or handle Dag version number
# TODO this also assume Dag node are number 1 to N (start at 1)


# TODO fire interface should accept multiple nodes at once (event group)
function fire(eve::EvalTSort, d::Dag, src_nid, src_v)
    # TODO assume Dag is static (or at least no new node can fire during fire)
    #      SimpleTrait could help here
    # TODO caching of tsort result, reuse of `firing` memory etc
    t_order = tsort(length(d.nodes), nid -> [n for (n,_) in d.links[nid] if n != 0])

    # TODO maybe have array of nullable instead of dict, and iterate in zip
    firing = Dict{Int, Any}(src_nid=>src_v)
    for nid in t_order
        !haskey(firing, nid) && continue

        nid_v = firing[nid]
        # TODO could remove from firing (and stop when firing is empty)

        targets = Base.get(d.links, nid, [])
        for (dst_nid, f) in targets
            # TODO ugly hack to register external callback
            if dst_nid == 0
                f(nid_v)
                continue
            end

            # TODO store dst directly in targets?
            dst = d.nodes[dst_nid]
            # assert dst must be in rest of t_order

            tv = f(nid_v)  # feed builder edge buffer
            if !isnull(tv)
                # nodes are evaluated in sequence, eliding previous values
                # i.e. if a node produce multiple values (triggered by multiple
                # parents) only the latest produced value is kept.
                firing[dst.nid] = get(tv)
            end
        end
    end
end
