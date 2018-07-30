using Base.Test

using Tick: Dag, node!, onfire!
using Tick: EvalDfs, EvalTSort, fire, tsort
using Tick: latest
using Tick: BVal, combine!, tr!
using Tick: add!, first!, last!, nth!, win!

# TODO FactCheck.jl

const testdir = dirname(@__FILE__)

@testset "Tick" begin
    include(joinpath(testdir, "evaldfs.jl"))
    include(joinpath(testdir, "evaltsort.jl"))
    include(joinpath(testdir, "combine.jl"))
    include(joinpath(testdir, "ops.jl"))
end
