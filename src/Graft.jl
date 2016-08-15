__precompile__(true)

module Graft

using DataFrames
using ProgressMeter

import Base: deepcopy, ==, +, -, |>

# Export DataFrame stuff
export NA


# Package Wide Utilities
include("util.jl")

# Edge Iteration
include("edgeiter.jl")

# SparseMatrixCSC compatibilty
include("sparsematrix.jl")

# Vertex Labelling
include("labelmap.jl")

# Basic Graph Definition
include("graph.jl")

# Subgraph
include("subgraph.jl")

# Graph IO
include("graphio.jl")

# Querying
include("query.jl")

# Graph Algortithms
include("algorithms.jl")

# Operations
include("operations/export.jl")
include("operations/merging.jl")


end # module
