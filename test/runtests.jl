using Base.Test

# using Tick

using Tick: RootTicker, Latest, Universe, NTicker, Ticker, Dag, make_node!, output_type, link!, EvalDfs, fire

import Tick: universe, tick

# TODO FactCheck.jl

const testdir = dirname(@__FILE__)

@testset "Tick" begin

    @testset "RootTicker" begin
        d = Dag()
        # RootTicker have empty Universe (by definition, no predecessors)
        @test isempty(universe(d, RootTicker{Int}()))
    end

    include(joinpath(testdir, "various.jl"))
end
