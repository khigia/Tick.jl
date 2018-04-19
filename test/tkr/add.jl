using Tick: BVal
using Tick.Tkr: Add

@testset "AddTicker" begin
    d = Dag()

    rn1 = make_node!(d, RootTicker{Int}())
    rn2 = make_node!(d, RootTicker{Int}())

    at = Add(rn1, rn2)
    @test length(universe(at)) == 2

    @inferred tick(at, BVal(Dict("left"=>1, "right"=>2), [2,3]))
    @test get(tick(at, BVal(Dict("left"=>1, "right"=>2), [2,3]))) == 5

    @inferred get(tick(at, Dict("left"=>3, "right"=>4)))
    @test get(tick(at, Dict("left"=>3, "right"=>4))) == 7
end
