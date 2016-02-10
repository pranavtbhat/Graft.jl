###
# WORKER HANDLE
###
type WorkerHandle
    id::ProcID                                                  # Unique process id. Same as myid().
    gvcount::VertexID                                           # Global vertex count.
    partitions::Dict{ProcID,UnitRange{Int}}                     # Mapping of process id's to vertex partitions.
    vertices::Vector{Vertex}                                    # Actual Vertex data.
end

const whandle = WorkerHandle(
    myid(),
    0,
    Dict{Int,UnitRange{Int}}(),
    Vector{Vertex}()
)

###
# CONTROL REMOTE CALLS
###
"""Executed remotely by master to set partitions on workers"""
function setpartitions(gvcount::VertexID, partitions::Dict{ProcID,UnitRange{Int}})
    global whandle
    whandle.gvcount = gvcount
    whandle.partitions = partitions
    nothing
end

"""Executed remotely by master to set fadjlists"""
function rsetfadjlists(fadj_lists::Vector{Vector{VertexID}})
    global whandle
    map(setfadj, whandle.vertices, fadj_lists)
    nothing
end

"""Executed remotely by master to set badjlists"""
function rsetbadjlists(badj_lists::Vector{Vector{VertexID}})
    global whandle
    map(setbadj, whandle.vertices, badj_lists)
    nothing
end

###
# VERTEX MESSAGING
###
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
