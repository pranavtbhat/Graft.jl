module ParallelGraphs

using ComputeFramework


include("graph.jl")
include("message.jl")
include("message-passing.jl")
include("show.jl")

    include("utilities/generators.jl")
    include("utilities/conversions.jl")

include("compute.jl")

    include("algorithms/connected-components.jl")
    include("algorithms/bfs.jl")

end # module
