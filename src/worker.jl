##
# This file should be included only on workers.
##
###
# WORKER HANDLE
###
type WorkerHandle
    id::ProcID                                                  # Unique process id. Same as myid().
    partitions::Dict{ProcID,UnitRange{Int}}                        # Mapping of process id's to vertex partitions.
    vertices::Vector{Vertex}                                    # Actual Vertex data.
    adj::GraphStruct                                            # Adjacency information
end

const whandle = WorkerHandle(
    myid(),
    Dict{Int,UnitRange{Int}}(),
    Vector{Vertex}(),
    NullStruct()
)


"""Executed remotely by master to set partitions on workers"""
function set_partitions(partitions::Dict{ProcID,UnitRange})
    global whandle
    whandle.partitions = partitions
    nothing
end

"""Return the partition to which the vertex belongs to"""
function vertextoproc(v::VertexID)
    global whandle
    for (pid,vrange) in whandle.partitions
        v in vrange && return pid
    end
    error("Vertex $v doesn't belong to any partition.")
end

function send_message(p::VertexPayload)
    dest_vertex = getdestvertex(vp)
    dest_proc =
