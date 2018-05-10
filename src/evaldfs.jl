struct EvalDfs end
# TODO doc sync, not real DFS

function fire(eve::EvalDfs, d::Dag, src_nid, v)
    # simple approach: DFS style triggering
    # TODO doc async behaviour
    # TODO able to fire multiple concurrently
    targets = Base.get(d.links, src_nid, [])
    # println("-- trigger $src_nid -> $targets")
    @sync for (dst_nid, f) in targets
        # TODO ugly hack to register external callback
        if dst_nid == 0
            @async f(v)
            continue
        end

        # TODO store dst directly in targets?
        dst = d.nodes[dst_nid]

        @async begin
            tv = f(v)
            if !isnull(tv)
                fire(eve, d, dst.nid, get(tv))
            end
        end
    end
end
