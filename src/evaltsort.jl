
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
    t_order = tsort(length(d.nodes), nid -> [n for (n,_) in d.links[nid] if n != 0])

    # TODO maybe have array of nullable instead of dict, and iterate in zip
    firing = Dict(src_nid=>src_v)
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

            begin
                cv = f(nid_v)  # feed builder edge buffer
                if cv
                    # Buf for this edge want to trigger the target node

                    # TODO generate could still fail (e.g. missing required input)
                    dd = generate(dst.builder)

                    tv = tick(dst.ticker, dd)

                    if !isnull(tv)
                        assert(!haskey(firing, dst.nid))
                        firing[dst.nid] = get(tv)
                        # TODO builder reset probably NOT depending on tick ...
                        reset(dst.builder)
                    end
                end
            end
        end
    end
end