##
# This file should be included only on workers.
##
###
# WORKER HANDLE
###
type WorkerHandle
    id::ProcID                                                  # Unique process id. Same as myid().
    num_partitions::Int                                         # Total number of partitions
    partitions::Dict{ProcID,UnitRange{Int}}                     # Mapping of process id's to vertex partitions.
    vertices::Vector{Vertex}                                    # Actual Vertex data.
    adj::GraphStruct                                            # Adjacency information
end

const whandle = WorkerHandle(
    myid(),
    0,
    Dict{Int,UnitRange{Int}}(),
    Vector{Vertex}(),
    NullStruct()
)

"""Executed remotely by master to set partitions on workers"""
function set_partitions(partitions::Dict{ProcID,UnitRange{Int}})
    global whandle
    whandle.partitions = partitions
    nothing
end

"""Return the partition to which the vertex belongs to"""
function vertextoproc(v::VertexID, w::Vector{ProcID} = Workers())
    global whandle
    div = whandle.num_partitions/length(w)
    w[round(Int, ceil(v/div))]
end

"""Find the proc on which the destination vertex resides on, and cache the message"""
function sendmessage(p::VertexPayload)
    dest_vertex = getdestvertex(vp)
    dest_proc = vertextoproc(dest_vertex)
    cachemessage(p, dest_proc)
end
