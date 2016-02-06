###
# WORKER HANDLE
###
type WorkerHandle
    id::Int                                                     # Unique process id. Same as myid().
    partitions::Dict{Int,UnitRange{Int}}                        # Mapping of process id's to vertex partitions.
    vertices::Vector{Vertex}                                    # Actual Vertex data.
    adj::GraphStruct                                            # Adjacency information
end

###
# MESSAGE HANDLE
###
type MessageHandle
    master_cref::RemoteChannel{Channel{ControlMessage}}         # Master's control message endpoint.
    master_dref::RemoteChannel{Channel{ControlMessage}}         # Master's data message endpoint.

    self_cref::RemoteChannel{Channel{ControlMessage}}           # Endpoint for incoming control messages.
    self_dref::RemoteChannel{Channel{DataMessage}}              # Endpoint for incoming data messages.

    data_refs::Dict{Int, RemoteChannel{Channel{DataMessage}}}   # Mapping from process id's to TCPSockets.
    proc_out_queue::Dict{Int,Vector{VeretexMessage}}    # Mapping of process id's to caches for outgoing vertex messages.
    vertex_in_queue::Vector{Vector{VeretexMessage}}     # Vector of incoming message queues.
end

const whandle = WorkerHandle(
    myid(),
    "localhost",
    "localhost",
    0,
    Dict{Int,UnitRange{Int}}(),
    Dict{Int,Tuple{ASCIIString,UInt16}}(),
    Dict{Int, TCPSocket()}(),
)

const mhandle = MessageHandle(
    0,
    0,
    0,
    0,
    Dict{Int,Tuple{ASCIIString,UInt16}}(),
    Dict{Int, TCPSocket}(),
    Dict{Int,Vector{VeretexMessage}}(),
    Vector{Vector{VeretexMessage}}()
)

###
# Data Incoming Server
###
function din_server()
    @async begin
        server = listen(DATA_PORT + myid())          # Need to handle exceptions here.
        while true
            sock = accept(server)
            @async begin
                global whandle
                while isopen(sock)
                    msg::Message = deserialize(sock)
                    process_message()



function set_host!(host_name::ASCIIString, master_name::ASCIIString, master_port::UInt16)
    global whandle
    whandle.host_name = host_name
    whandle.master_name = master_name
    whandle.master_port = master_port



function set_partitions!(partitions::Dict{Int,UnitRange{Int}})
    global whandle
    whandle.partitions = partitions
    nothing
end

function set_connections!(socket_info::Dict{Int,Tuple{ASCIIString,UInt16}})
    global whandle
    whandle.socket_info = socket_info
    for (pid,sock_addr) in socket_info
        whandle.connections[pid] = connect(sock_addr...)
    end
    nothing
end
