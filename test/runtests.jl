addprocs(2)
using ParallelGraphs
using Base.Test

# write your own tests here
include("graph.jl")

    include("messaging/message.jl")
    include("messaging/message-passing.jl")

    include("utilities/generators.jl")
    include("utilities/conversions.jl")

include("compute.jl")

    include("algorithms/connected-components.jl")
    include("algorithms/bfs.jl")
