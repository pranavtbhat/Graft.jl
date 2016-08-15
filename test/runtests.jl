using Base.Test

using Graft

import Graft: eltypes, randindxs, completeindxs, LabelMap, IdentityLM, DictLM,
bfs, bfs_list, bfs_tree, bfs_subgraph

###
# TEST FILES
###
include("util.jl")

include("sparsematrix.jl")

include("edgeiter.jl")

include("labelmap.jl")

include("graph.jl")

include("generator.jl")

include("combinatorial.jl")

include("vdata.jl")

include("edata.jl")

include("mutation.jl")

include("display.jl")

include("graphio.jl")

include("subgraph.jl")

include("algorithms.jl")

include("operations.jl")

include("query.jl")
