"""A RemoteChannel that functions as a message buffer"""
typealias MessageBox RemoteChannel{Channel{Message}}

"""
An interface for passing messages between ALL processes including the main process.
"""
type MessageInterface
    mgrid::Array{MessageBox,2}              # Distrbitued Message Grid.
    metadata::Vector{UnitRange{Int}}        # Vertex distribution metadata.
    barrier::Vector{RemoteChannel{Channel{Bool}}} # Synchronization barrier
end

###
# CONSTRUCTORS
##
"""
Generate a matrix of MessageBoxes.The [i,j]th MessageBox is a buffer
for messages from process i to process j. The jth column therefore stores all messages
directed to a process.
"""
function get_mgrid(;proc_list=procs(), buf_size=typemax(Int))
    hcat(map(pid->MessageBox[RemoteChannel(()->Channel{Message}(buf_size), pid) for i in proc_list], proc_list)...)
end

"""
Generate a vector of RemoteChannels. When the (i-1)th channel is *ready*, it indicates
that the ith worker has finished an iteration.
"""
function get_barrier(proclist=workers())
    map(pid->RemoteChannel(()->Channel{Bool}(1), pid), proclist)
end

"""
Initialize the message passing interface. Should be called only from the main
process.
"""
function message_interface(metadata::Vector)
    mgrid = get_mgrid()
    unshift!(metadata, 0:0)
    MessageInterface(mgrid, Vector{UnitRange{Int}}(metadata), get_barrier())
end

###
# ACCESSOR METHODS
###
"""Get a worker's lock"""
function get_lock(mint::MessageInterface, w::Int=myid())
    mint.barrier[w-1]
end

"""Get the process to which the vertex has been assigned"""
function get_parent(mint::MessageInterface, v::Int)
    findfirst(x-> v in x, mint.metadata)
end

"""Get a worker's local vertices"""
function get_local_vertices(mint::MessageInterface, w::Int=myid())
    mint.metadata[w]
end

"""Get the MessageBox for a given source and destination"""
function get_out_mbox(mint::MessageInterface, src::Int, dest::Int)
    mint.mgrid[src,dest]
end

"""Get the list of message boxes containing incoming messages for a process"""
function get_in_mboxes(mint::MessageInterface, dest::Int)
    mint.mgrid[:,dest]
end

###
# MESSAGING FUNCTIONS
###
""" Send a message to the target vertex """
function send_message!(mint::MessageInterface, m::Message, w=myid())
    target_proc = get_parent(mint, get_dest(m))
    put!(get_out_mbox(mint, w, target_proc), m)
    nothing
end

"""
Receive all messages sent to process. Divides the messages based on the destination
vertex.
"""
function receive_messages!(mint::MessageInterface, w::Int=myid())
    vrange = get_local_vertices(mint::MessageInterface, w)
    vmq = [MessageQueue() for i in vrange]
    for mbox in get_in_mboxes(mint, w)
        while isready(mbox)
            m = take!(mbox)
            push!(vmq[get_dest(m)-start(vrange)+1], m)
        end
    end
    vmq
end

###
# SYNCHRONIZATION
###
"""Signal the end of a workers execution"""
function barrier_signal(mint::MessageInterface, w::Int=myid())
    put!(get_lock(mint,w), true)
end

"""Wait for all workers to signal (should be called on the main proc only)"""
function barrier_wait(mint::MessageInterface)
    for w in workers()
        take!(get_lock(mint, w))
    end
end
