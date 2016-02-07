###
# WORKER HANDLE
###
type WorkerHandle
    id::ProcID                                                  # Unique process id. Same as myid().
    partitions::Dict{Int,UnitRange{Int}}                        # Mapping of process id's to vertex partitions.
    vertices::Vector{Vertex}                                    # Actual Vertex data.
    adj::GraphStruct                                            # Adjacency information
end

const whandle = WorkerHandle(
    myid(),
    Dict{Int,UnitRange{Int}}(),
    Vector{Vertex}(),
    NullStruct()
)
