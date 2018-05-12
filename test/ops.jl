@testset "add!" begin
    d = Dag()

    rn1 = node!(d, Int32)
    rn2 = node!(d, Int64)

    parents = [
        ("left", rn1, Latest(0), true),
        ("right", rn2, Latest(0), false),
    ]
    an = add!(d, parents)
    @test Tick.eltype(an) == Int64  # promoted

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
