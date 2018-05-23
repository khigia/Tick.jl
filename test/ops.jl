@testset "Ops" begin
    @testset "add!" begin
        d = Dag()

        rn1 = node!(d, Int32)
        rn2 = node!(d, Int64)

        # complete form using combine! inetrnally
        parents = [
            ("left", rn1, latest(0), true),
            ("right", rn2, latest(0), false),
        ]
        an = add!(d, parents)
        @test Tick.eltype(an) == Int64  # promoted

        # short form assuming init value and always triggering
        an2 = add!(d, rn1, rn2)
        @test Tick.eltype(an2) == Int64  # promoted

        res = []
        onfire!(d, an.nid, v -> push!(res, v))

        res2 = []
        onfire!(d, an2.nid, v -> push!(res2, v))

        eve = EvalDfs()
        fire(eve, d, rn1.nid, 42)
        @test res == [42]
        @test res2 == [42]

        fire(eve, d, rn2.nid, 42)
        @test res == [42]
        @test res2 == [42, 84]

        fire(eve, d, rn1.nid, 41)
        @test res == [42, 83]
        @test res2 == [42, 84, 83]
    end

    @testset "first!" begin
        d = Dag()

        pn = node!(d, Tuple{Int,String})
        an = first!(d, pn)
        @test Tick.eltype(an) == Int

        res = []
        onfire!(d, an.nid, v -> push!(res, v))

        eve = EvalDfs()
        fire(eve, d, pn.nid, (42, "fortytwo"))
        @test res == [42]
    end

    @testset "last!" begin
        d = Dag()

        pn = node!(d, Tuple{Int,String})
        an = last!(d, pn)
        @test Tick.eltype(an) == String

        res = []
        onfire!(d, an.nid, v -> push!(res, v))

        eve = EvalDfs()
        fire(eve, d, pn.nid, (42, "fortytwo"))
        @test res == ["fortytwo"]
    end
end
