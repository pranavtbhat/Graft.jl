export minitialize

##
# This file should be included only on the master process.
##
type MasterHandle
    n::VertexID
    num_procs::ProcID
    partitions::Dict{ProcID,UnitRange{Int}}
end

const mhandle = MasterHandle(
    0,
    1,
    Dict{ProcID,UnitRange{Int}}()
)

"""Partition a range of vertices to all available workers"""
function partition(num_vertices::Int, w=workers())
    global mhandle

    num_vertices < length(w) && error("There must be atlease one vertex per process!")
    starts = round(Int, linspace(1, num_vertices+1, length(w)+1))
    vranges = map(UnitRange{Int}, starts[1:end-1], starts[2:end] .- 1)
    partitions = Dict{ProcID,UnitRange{Int}}()

    for i in eachindex(w)
        partitions[w[i]] = vranges[i]
    end

    mhandle.partitions = partitions

    for pid in w
        remotecall_fetch(set_partitions, pid, partitions)
    end
end
