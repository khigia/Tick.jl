struct EvalDfs end

function fire(eve::EvalDfs, d::Dag, src_nid, v)
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
        # assert dst is not RootTicker

        @async begin
            cv = f(v)  # feed builder edge buffer
            if cv
                # Buf for this edge want to trigger the target node

                # TODO generate could still fail (e.g. missing required input)
                dd = generate(dst.builder)

                tv = tick(dst.ticker, dd)

                # simple approach: DFS style triggering
                # TODO could store trigger, continue current trigger, and continue after (BFS style)
                # or even use a toposort order and
                if !isnull(tv)
                    fire(eve, d, dst.nid, get(tv))
                end

                if !isnull(tv)
                    # TODO builder reset probably NOT depending on tick ...
                    reset(dst.builder)
                end
            end
        end
    end
end
