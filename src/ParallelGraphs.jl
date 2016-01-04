module ParallelGraphs

using LightGraphs
import ComputeFramework: ComputeNode, compute, Context, distribute, gather, redistribute

export

# ComputeFramework essentials
compute, Context, gather, distribute, redistribute

include("graph.jl")
include("message.jl")
include("message-passing.jl")
include("indexing.jl")
include("compute.jl")

include("show.jl")

include("algorithms/bfs.jl")
end # module
