addprocs(2)
using ParallelGraphs
using Base.Test


# Graph Structures
import ParallelGraphs: VertexProperty, NullProperty, Vertex, getid, getlabel, isactive,
    getfadj, getbadj, getproperty, setlabel!, activate!, deactivate!, setfadj!,
    setbadj!, setproperty!, rmproperty!
include("graph.jl")

# Message Passing Definitions
import ParallelGraphs: Message, getdest, getval, DataMessage, ControlMessage,
    Batch, ControlEndpoint, DataEndpoint
include("messaging/message.jl")

# Control Messages
import ParallelGraphs: PartitionMessage, LoadMessage, WorkerStatus, StatusMessage
include("messaging/control-messages.jl")

# Data Messages
import ParallelGraphs: VertexPayload, getdestvertex, DebugPayload, VertexMessage
include("messaging/data-messages.jl")

# Message Passing Core
import ParallelGraphs: cin_ref, cout_refs, dout_refs, din_refs, proc_out_queue,
    vertex_in_queue, data_in_queue, data_in_queue, fetchrefs, register, cachepayload,
    sendmessage, syncmessages, receivemessages
include("messaging/message-passing.jl")
