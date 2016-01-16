module ParallelGraphs

using ComputeFramework


include("graph.jl")
include("message.jl")
include("message-passing.jl")
include("indexing.jl")
include("compute.jl")
include("show.jl")

    include("algorithms/connected-components.jl")
    # include("algorithms/bfs.jl")

    include("utilities/generators.jl")
    include("utilities/conversions.jl")
end # module
