using Base.Test

using Tick: Dag, RootTicker, make_node!, onfire!, universe, tick
using Tick: EvalDfs, fire
using Tick: BVal, Latest
using Tick.Tkr: Add

# TODO FactCheck.jl

const testdir = dirname(@__FILE__)

@testset "Tick" begin

    @testset "RootTicker" begin
        d = Dag()
        # RootTicker have empty Universe (by definition, no predecessors)
        @test isempty(universe(RootTicker{Int}()))
    end

    include(joinpath(testdir, "evaldfs.jl"))
    include(joinpath(testdir, "tkr/add.jl"))
end
