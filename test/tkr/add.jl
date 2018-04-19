@testset "AddTicker" begin
    d = Dag()

    rn1 = make_node!(d, RootTicker{Int32}())
    rn2 = make_node!(d, RootTicker{Int64}())


    at = Add(rn1, rn2)
    @test typeof(at) == Add{Int64}  # promoted

    @test length(universe(at)) == 2

    # TODO below looks like BVal utilities
    cols = first.(universe(at))
    keys = reverse.(cols |> enumerate |> collect) |> Dict
    inputs(xs) = Dict(zip(cols, xs))

    @inferred tick(at, BVal(keys, [2,3]))
    @test get(tick(at, BVal(keys, [2,3]))) == 5

    @inferred get(tick(at, inputs([3,4])))
    @test get(tick(at, inputs([3,4]))) == 7
end
