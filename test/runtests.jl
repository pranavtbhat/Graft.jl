using Base.Test

using ParallelGraphs

import ParallelGraphs: randindxs, completeindxs

###
# TEST FILES
###
include("util.jl")

include("SparseMatrixCSC.jl")

include("edgeiter.jl")

include("labelmap.jl")

include("graph.jl")

include("combinatorial.jl")

include("vdata.jl")

include("edata.jl")

include("mutation.jl")

include("generator.jl")

# include("subgraph.jl")
#
# include("query.jl")
#
# include("filter.jl")
#
# include("parse.jl")
#
# include("algorithms.jl")
#
# include("conv.jl")
