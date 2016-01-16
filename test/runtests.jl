addprocs(2)
using ParallelGraphs
using Base.Test

# write your own tests here
include("graph.jl")
include("message.jl")
include("message-passing.jl")

    include("utilities/generators.jl")
    include("utilities/conversions.jl")

include("compute.jl")
