module BSP

import Base: push!, empty!

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
    f::Function
    seed::Int
    graph::Any
end
bsp(f,seed,graph) = BSPNode(f,seed,graph)

include("indexing.jl")
include("message-passing.jl")
include("compute.jl")
include("show.jl")

end # module
