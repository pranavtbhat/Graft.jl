module ParallelGraphs

using StatsBase
using DataFrames

import Base: deepcopy, ==, +, -, |>

# Export DataFrame stuff
export NA


# Package Wide Utilities
include("util.jl")

# Edge Iteration
include("edgeiter.jl")

# SparseMatrixCSC compatibilty
include("SparseMatrixCSC.jl")

# Vertex Labelling
include("labelmap.jl")

# Basic Graph Definition
include("graph.jl")

# Graph Generators
include("generator.jl")

# # Graph Algortithms
# include("algorithms.jl")
#
#
# # Operations
# include("ops/export.jl")
# include("ops/condensation.jl")
# include("ops/merging.jl")
#
# # Parse Graphs from files etc.
# include("graphio.jl")
#
# # Querying
# include("query.jl")

end # module
