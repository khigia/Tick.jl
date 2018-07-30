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

    @testset "nth!" begin
        d = Dag()

        pn = node!(d, Tuple{Int,String,Float64})
        an = nth!(d, pn, 2)
        @test Tick.eltype(an) == String

        res = []
        onfire!(d, an.nid, v -> push!(res, v))

        eve = EvalDfs()
        fire(eve, d, pn.nid, (42, "fortytwo", 3.14))
        @test res == ["fortytwo"]
    end

    @testset "win!" begin
        d = Dag()

        pn = node!(d, Int)

        an = win!(d, pn, 3)
        @test Tick.eltype(an) == Vector{Int}

        wn = win!(d, pn, 3)
        ma = tr!(d, wn, mean)
        @test Tick.eltype(ma) == Float64
        # TODO is passing transformer here ok? shouldn't transformer just be
        #      a new node? it seems more efficient this way, but is it right?
        #      maybe only for this case we can enforce a Trait/Type on
        #      transformer

        res = []
        resf = []
        onfire!(d, an.nid, v -> push!(res, copy(v)))
        onfire!(d, ma.nid, v -> push!(resf, v))

        eve = EvalDfs()
        fire(eve, d, pn.nid, 1)
        @test res == [[1]]
        @test resf == [1.0]
        fire(eve, d, pn.nid, 2)
        @test res == [[1], [1,2]]
        @test resf ≈ [1.0, 1.5]
        fire(eve, d, pn.nid, 3)
        @test res == [[1], [1,2], [1,2,3]]
        @test resf ≈ [1.0, 1.5, 2.0]
        fire(eve, d, pn.nid, 4)
        @test res == [[1], [1,2], [1,2,3], [2,3,4]]
        @test resf ≈ [1.0, 1.5, 2.0, 3.0]
    end

    # TODO can we do something like?
    #   d |>> node!(Int) |>> win!(3) |>> tr!(Float, mean)
end
