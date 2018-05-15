@testset "EvalDfs" begin
    @testset "triggering" begin
        d = Dag()

        rn1 = node!(d, Int64)
        rn2 = node!(d, Int64)

        an = add!(d, [
            ("left", rn1, Latest(0), true),
            ("right", rn2, Latest(0), false),
        ])

        res = Dict()
        onfire!(d, rn1.nid, v -> push!(get!(res, "rn1", []), v))
        onfire!(d, rn2.nid, v -> push!(get!(res, "rn2", []), v))
        onfire!(d, an.nid, v -> push!(get!(res, "an", []), v))

        eve = EvalDfs()
        fire(eve, d, rn1.nid, 42)
        @test res["rn1"] == [42]
        # TODO check throw @test res["rn1"] == [42]
        @test res["an"] == [42]

        fire(eve, d, rn2.nid, 24)  # does not trigger `an` display
        @test res["rn1"] == [42]
        @test res["rn2"] == [24]
        @test res["an"] == [42]

        fire(eve, d, rn1.nid, 642)
        @test res["rn1"] == [42, 642]
        @test res["rn2"] == [24]
        @test res["an"] == [42, 666]
    end

    @testset "not eliding" begin
        d = Dag()

        rn1 = node!(d, Tuple{Int64, Int64})
        rn11 = first!(d, rn1)
        rn12 = last!(d, rn1)

        an = add!(d, [
            ("left", rn11, Latest(0), true),
            ("right", rn12, Latest(0), true),
        ])

        res = Dict()
        onfire!(d, an.nid, v -> push!(get!(res, "an", []), v))

        eve = EvalDfs()
        fire(eve, d, rn1.nid, (1, 2))
        @test res["an"] == [1, 3]
    end
end
