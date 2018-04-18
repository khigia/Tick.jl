using Tick: BVal


struct Add <: Ticker{Int}
    left_node
    right_node
end

function universe(d::Dag, tkr::Add)
    [
        NTicker("left", tkr.left_node, () -> Latest(0), true),
        NTicker("right", tkr.right_node, () -> Latest(0), false),
    ]
end

function tick(tkr::Add, input)::Nullable{output_type(tkr)}
    return Nullable(input["left"] + input["right"])
end



@testset "AddTicker" begin
    d = Dag()

    rn1 = make_node!(d, RootTicker{Int}())
    rn2 = make_node!(d, RootTicker{Int}())

    at = Add(rn1, rn2)
    @test length(universe(d, at)) == 2

    @inferred tick(at, BVal(Dict("left"=>1, "right"=>2), [2,3]))
    @test get(tick(at, BVal(Dict("left"=>1, "right"=>2), [2,3]))) == 5

    @inferred get(tick(at, Dict("left"=>3, "right"=>4)))
    @test get(tick(at, Dict("left"=>3, "right"=>4))) == 7

    an = make_node!(d, at)

    res = Dict()
    link!(d, rn1.nid, 0, v -> push!(get!(res, "rn1", []), v))
    link!(d, rn2.nid, 0, v -> push!(get!(res, "rn2", []), v))
    link!(d, an.nid, 0, v -> push!(get!(res, "an", []), v))

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
