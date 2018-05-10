using Base.Test

using Tick: Dag, make_node!, onfire!
using Tick: EvalDfs, EvalTSort, fire
using Tick: BVal, Latest, combine!
using Tick: tsort
using Tick.Tkr: add!

# TODO FactCheck.jl

const testdir = dirname(@__FILE__)

@testset "Tick" begin
    include(joinpath(testdir, "evaldfs.jl"))
    include(joinpath(testdir, "buf.jl"))
    include(joinpath(testdir, "evaltsort.jl"))
    include(joinpath(testdir, "tkr/add.jl"))
end
