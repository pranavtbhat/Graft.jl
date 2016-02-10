###
# PARTITION MESSAGE TYPE
###
"""Sent from the master to a worker, assigning a partition of the vertices"""
immutable PartitionMessage <: ControlMessage
    dest::ProcID
    value::UnitRange{Int}
end

###
# LOAD MESSAGE TYPE
###
"""Sent from master to a worker, instructing the worker to load adjacency data"""
abstract LoadMessage <: ControlMessage

###
# STATUS MESSAGE
###
"""Structure containing a worker's status, sent to master at the end of every job"""
immutable WorkerStatus
    id::Int
    success::Bool
    num_active::Int
    error::Exception
    trace::AbstractString
end

"""Worker's status sent to the master process"""
immutable StatusMessage <: ControlMessage
    dest::Int
    value::WorkerStatus
end
