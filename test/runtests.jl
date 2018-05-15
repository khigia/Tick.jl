using Base.Test

using Tick: Dag, node!, onfire!
using Tick: EvalDfs, EvalTSort, fire, tsort
using Tick: Latest
using Tick: BVal, Latest, combine!
using Tick: add!, first!, last!

# TODO FactCheck.jl

const testdir = dirname(@__FILE__)

@testset "Tick" begin
    # include(joinpath(testdir, "dag.jl"))
    include(joinpath(testdir, "evaldfs.jl"))
    include(joinpath(testdir, "evaltsort.jl"))
    # include(joinpath(testdir, "buf.jl"))
    include(joinpath(testdir, "combine.jl"))
    include(joinpath(testdir, "ops.jl"))
end
