module ParallelGraphs

using ComputeFramework

# Package wide definitions
include("definitions.jl")

# Graph Structures
include("graph.jl")

# Serial Execution

# Parallel Execution

# Distributed Execution

    # Message Passing
    include("distributed/messaging/message.jl")
    include("distributed/messaging/data-messages.jl")
    include("distributed/messaging/message-passing.jl")

    # Algorithms

end # module
