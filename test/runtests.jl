
if VERSION < v"0.5.0-dev"
    using BaseTestNext
else
    using Base.Test
end

using ParallelGraphs

include("adjacency.jl")

include("properties.jl")

include("subgraph.jl")

include("query.jl")

include("filter.jl")

include("algorithms.jl")

