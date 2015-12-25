module BSPWorker

export

bspIteration,

getParentProc, getLocalIndex, getGlobalVertex,

Message, MessageAggregate, ActivateMessage, processMessage, generateMQ, push!

# package code goes here
include("compute.jl")
include("indexing.jl")
include("message-passing.jl")
end # module
