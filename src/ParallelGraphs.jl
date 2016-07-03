module ParallelGraphs

const CAN_USE_LG = begin
   try
      import LightGraphs
      true
   catch e
      println(e)
      println("Cannot load LightGraphs. LightGraphsAM will be disabled.")
      false
   end
end


using Faker

import Base: deepcopy

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
