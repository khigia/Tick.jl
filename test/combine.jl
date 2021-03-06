import Base.==

# TODO move to combine
==(x::BVal, y::BVal) = x.fields == y.fields && x.val == y.val


@testset "Combine" begin

    @testset "combine!" begin
        d = Dag()

        rn1 = node!(d, Int32)
        rn2 = node!(d, Int64)
        parents = [
            ("left", rn1, latest(0), true),
            ("right", rn2, latest(0), false),
        ]
        an = combine!(d, parents)

        # TODO below looks like BVal utilities
        cols = first.(parents)
        keys = reverse.(cols |> enumerate |> collect) |> Dict
        inputs(xs) = Dict(zip(cols, xs))

        res = []
        onfire!(d, an.nid, v -> push!(res, v))

        eve = EvalDfs()
        fire(eve, d, rn1.nid, 42)
        @test res == Any[BVal(keys, (42, 0))]

        # TODO for testing, would be cool to have a value(an) to get latest
        #      produced value ... might as well be useful outside testing
    end

    # TODO apply!

    @testset "tr!" begin
        d = Dag()

        inn = node!(d, Int32)
        oun = tr!(d, inn, x->2x)

        res = []
        onfire!(d, oun.nid, v -> push!(res, v))

        eve = EvalDfs()
        fire(eve, d, inn.nid, 42)
        @test res == [84]
    end
end
