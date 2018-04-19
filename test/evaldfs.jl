
@testset "EvalDfs" begin
    d = Dag()

    rn1 = make_node!(d, RootTicker{Int}())
    rn2 = make_node!(d, RootTicker{Int}())

    an = make_node!(d,
        Add(rn1, rn2),
        [
            (() -> Latest(0), true),
            (() -> Latest(0), false),
        ]
    )

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
