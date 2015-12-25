module BSP

import ComputeFramework: ComputeNode, compute, Context, distribute, gather

export

# ComputeFramework essentials
compute, Context,

# BSP main
bsp,

# Iteration function for workers
bspIteration,

# auxillary indexing functions for workers
getParentProc, getLocalIndex, getGlobalVertex, getRanges,

# Message passing for main and workers
Message, ActivateMessage, MessageAggregate, processMessage, push!, generateMQ



### ComputeNode for Bulk Syncrhonous Parallel processing ###
immutable BSPNode <: ComputeNode
    seed::Int
    graph::Any
end
bsp(seed,graph) = BSPNode(seed,graph)

include("indexing.jl")
include("message-passing.jl")
include("compute.jl")

end # module
