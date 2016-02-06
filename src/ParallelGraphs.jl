__precompile__(true)

module ParallelGraphs

using ComputeFramework

"""Package-Wide aliases"""
typealias VertexID Int
typealias VertexLabel ASCIIString
typealias ProcID Int

# Graph Structures
include("graph.jl")

# Message Passing
include("messaging/message.jl")
include("messaging/control-messages.jl")
include("messaging/data-messages.jl")
include("messaging/message-passing.jl")

# Repl Helpers
include("show.jl")

# Utilities
include("utilities/generators.jl")
include("utilities/conversions.jl")

# Core computation definitions
include("compute.jl")

# Algorithms
include("algorithms/connected-components.jl")
include("algorithms/bfs.jl")

end # module
