"""
    Tick

Tick is a great module^** full of GoodThings.

** terms and conditions apply.
"""
module Tick

export tick, universe



abstract type Ticker{T} end

output_type(_::Ticker{T}) where {T} = T

tick(_::Ticker{T}, builder_value) where {T} = Nullable{T}()



struct RootTicker{T} <: Ticker{T} end

universe(_::RootTicker{T}) where {T} = Universe()



include("dag.jl")
include("evaldfs.jl")
include("buf.jl")


module Tkr

using Tick: Node, NTicker, Ticker, output_type, Latest
import Tick: universe, tick

include("tkr/add.jl")

end

end
