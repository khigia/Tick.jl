"""
    Tick

Tick is a great module^** full of GoodThings.

** terms and conditions apply.
"""
module Tick

include("dag.jl")
include("evaldfs.jl")
include("evaltsort.jl")
include("buf.jl")


module Tkr

using Tick: Dag, Node, Latest, combine!, make_node!, eltype

include("tkr/add.jl")

end

end
