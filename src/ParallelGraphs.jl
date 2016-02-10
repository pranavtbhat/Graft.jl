module ParallelGraphs

using ComputeFramework

# Package wide definitions
include("definitions.jl")

# Graph Structures
include("graph.jl")

# Message Passing
include("messaging/message.jl")
include("messaging/control-messages.jl")
include("messaging/data-messages.jl")
include("messaging/message-passing.jl")

# Core functioning
include("master.jl")
include("worker.jl")

# Repl Helpers
# include("show.jl")

# Utilities
# include("utilities/generators.jl")
# include("utilities/conversions.jl")

# Core computation definitions
# include("compute.jl")

# Algorithms
# include("algorithms/connected-components.jl")
# include("algorithms/bfs.jl")

end # module
