@testset "EvalTSort" begin

    @testset "tsort" begin
        # For test, reverse node order to expect output in same order
        _tsort(a) = tsort(length(a), i->a[i])

        @test _tsort([
            [3],
            [3],
            [],
        ]) == [2, 1, 3]

        @test _tsort([
            [4],
            [4, 5],
            [5, 8],
            [6, 7, 8],
            [7],
            [],
            [],
            [],
        ]) == [3, 2, 5, 1, 4, 6, 7, 8]

        @test _tsort([
            [],
            [],
            [4],
            [2],
            [1, 2],
            [1, 3],
        ]) == [6, 5, 3, 4, 2, 1]

        @test _tsort([
            [3, 4],
            [4, 5, 8],
            [6, 9],
            [6, 7],
            [7],
            [9],
            [8],
            [10],
            [10],
            [],
        ]) == [2, 5, 1, 3, 4, 6, 9, 7, 8, 10]
    end

    @testset "fire" begin
        # TODO can share one example/test between DFS and TSORT to show diff?
        d = Dag()

        rn1 = make_node!(d, Int64)
        rn2 = make_node!(d, Int64)

        # rn12 = combine!(d, [
        #     ("left", rn1, Latest(0), true),
        #     ("right", rn2, Latest(0), true),
        # ])
        # an = make_node!(d, Int64, [
        #     (rn12, v -> Nullable(v["left"] + v["right"])),
        # ])
        an = add!(d, [
            ("left", rn1, Latest(0), true),
            ("right", rn2, Latest(0), true),
        ])

        res = []
        onfire!(d, rn1.nid, v -> push!(res, "rn1:$v"))
        onfire!(d, rn2.nid, v -> push!(res, "rn2:$v"))
        onfire!(d, an.nid, v -> push!(res, "an:$v"))

        eve = EvalTSort()
        fire(eve, d, rn1.nid, 42)
        @test res == ["rn1:42", "an:42"]
    end

end
