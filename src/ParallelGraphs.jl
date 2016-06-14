module ParallelGraphs

using NDSparseData
import LightGraphs
using Faker

# Package Wide Utilities
include("util.jl")

# Property Modules
include("properties.jl")

# Adjacency Modules
include("adjacency.jl")

# Vertex Labelling
include("labelmodule.jl")

# Basic Graph Definition
include("graph.jl")

# Querying
include("query.jl")

# Parse Graphs from files etc.
include("parse.jl")

# Graph Algortithms
include("algorithms.jl")

end # module
