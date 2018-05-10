import Base.==

==(x::BVal, y::BVal) = x.fields == y.fields && x.val == y.val


@testset "Buf" begin
    d = Dag()

    rn1 = make_node!(d, Int32)
    rn2 = make_node!(d, Int64)
    parents = [
        ("left", rn1, Latest(0), true),
        ("right", rn2, Latest(0), false),
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
    @test res == Any[BVal(keys, [42,0])]

    # TODO for testing, would be cool to have a value(an) to get latest
    #      produced value ... might as well be useful outside testing
end
