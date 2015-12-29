module BSP

using LightGraphs
import ComputeFramework: ComputeNode, compute, Context, distribute, gather

export

# ComputeFramework essentials
compute, Context, gather, distribute,

# BSP main
bsp,

# Iteration function for workers
bspIteration,

# auxillary indexing functions for workers
getParentProc, getLocalIndex, getGlobalVertex, getRanges,

# Message passing for main and workers
Message, ActivateMessage, MessageAggregate, processMessage, push!, generateMQ,

# Layouts
DistGraph, GraphLayout, slice

include("compute-node.jl")
include("indexing.jl")
include("message-passing.jl")
include("compute.jl")
include("show.jl")

end # module
