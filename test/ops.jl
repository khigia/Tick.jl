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

    res = []
    onfire!(d, an.nid, v -> push!(res, v))

    eve = EvalDfs()
    fire(eve, d, rn1.nid, 42)
    @test res == [42]

    fire(eve, d, rn2.nid, 42)
    @test res == [42]

    fire(eve, d, rn1.nid, 42)
    @test res == [42, 84]

end
