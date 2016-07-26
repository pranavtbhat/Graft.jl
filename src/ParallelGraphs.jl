module ParallelGraphs

const CAN_USE_LG = false
# begin
#    try
#       import LightGraphs
#       true
#    catch e
#       println(e)
#       println("Cannot load LightGraphs. LightGraphsAM will be disabled.")
#       false
#    end
# end


using Faker

import Base: deepcopy, ==, +, -, |>

# Package Wide Utilities
include("util.jl")

# Adjacency Modules
include("adjacency.jl")

# Property Modules
include("properties.jl")

# Vertex Labelling
include("labelmodule.jl")

# Basic Graph Definition
include("graph.jl")

# Graph Generators
include("generator.jl")

# Core implementation
include("core/getvprop.jl")
include("core/geteprop.jl")
include("core/setvprop.jl")
include("core/seteprop.jl")

# Querying
include("query.jl")

# Parse Graphs from files etc.
include("parse.jl")

# Graph Algortithms
include("algorithms.jl")

end # module
