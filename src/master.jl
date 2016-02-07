##
# This file should be included only on the master process.
##
type MasterHandle
    partitions::Dict{ProcID,UnitRange{Int}}
end

function partition(num_vertices::Int, num_procs=length(procs()))
    num < num_procs && error("There must be atlease one vertex per process!")
    starts = round(Int, linspace(1, num_vertices+1, num_procs+1))
    map(UnitRange{Int}, starts[1:end-1], starts[2:end] .- 1)
end
