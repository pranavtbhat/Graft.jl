addprocs(2)
using ParallelGraphs
using Base.Test

import ParallelGraphs: cgraph, rgraph, rdigraph, rwgraph, rwdigraph
include("generator.jl")

import ParallelGraphs: bfs
include("traversals.jl")

include("paths.jl")
