module Tick

import Base.push!

include("dag.jl")
include("evaldfs.jl")
include("evaltsort.jl")
include("combine.jl")
include("ops.jl")

end
