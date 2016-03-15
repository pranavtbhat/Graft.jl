addprocs(2)
using ParallelGraphs
using Base.Test


# Graph Structures
import ParallelGraphs: VertexProperty, NullProperty, Vertex, getid, getlabel, isactive,
    getfadj, getbadj, getproperty, setlabel!, activate!, deactivate!, setfadj!,
    setbadj!, setproperty!, rmproperty!
include("graph.jl")

# Message Passing Definitions
import ParallelGraphs: Message, getdest, getval, Batch, Endpoint
include("distributed/messaging/message.jl")

# Data Messages
import ParallelGraphs: VertexPayload, getdestvertex, DebugPayload, VertexMessage
include("distributed/messaging/data-messages.jl")

# Message Passing Core
import ParallelGraphs: in_refs, out_refs, vm_caches, vm_buffers, in_queue, fetchrefs,
register, minitialize, cachepayload, sendmessage, syncmessages, receivemessages
include("distributed/messaging/message-passing.jl")
