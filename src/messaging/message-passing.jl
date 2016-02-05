"""A RemoteChannel that functions as a message buffer"""
typealias MessageBox RemoteChannel{Channel{MessageAggregate}}

"""
An interface for passing messages between ALL processes including the main process.
"""
immutable MessageInterface
    mgrid::Array{MessageBox,2}              # Distrbitued Message Grid.
    metadata::Vector{UnitRange{Int}}        # Vertex distribution metadata.
    cache::Dict{Int, MessageAggregate}      # Cache to accumulate messages.
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
    hcat(map(pid->MessageBox[RemoteChannel(()->Channel{MessageAggregate}(buf_size), pid) for i in proc_list], proc_list)...)
end

"""
Generate a vector of RemoteChannels. When the (i-1)th channel is *ready*, it indicates
that the ith worker has finished an iteration.
"""
function get_barrier(proclist=workers())
    map(pid->RemoteChannel(()->Channel{Bool}(1), pid), proclist)
end

"""
Generate a vector of MessageAggregates. Each process recieves a cache containing
MessageAggregates for each process. Outgoing messages are placed in the appropriate
cache before being dispatched in bulk.
"""
function get_cache(proclist=procs())
    Dict{Int, MessageAggregate}()
end

"""
Initialize the message passing interface. Should be called only from the main
process.
"""
function message_interface(metadata::Vector)
    mgrid = get_mgrid()
    unshift!(metadata, 0:0)
    MessageInterface(mgrid, Vector{UnitRange{Int}}(metadata), get_cache(), get_barrier())
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

###
# MESSAGING FUNCTIONS
###
""" Place a message in cache. Should be called in the transmitting process."""
function send_message!(mint::MessageInterface, m::Message, w=myid())
    # put!(mint.count, 1)
    target_proc = get_parent(mint, get_dest(m))
    push!(get!(mint.cache, target_proc, MessageAggregate()), m)
    nothing
end

"""
Compress contents of cache with user defined function and transfer to
remote channels.
"""
function transmit!(mint, w=myid())
    for (target_proc,ma) in mint.cache
        put!(mint.mgrid[w, target_proc], copy(ma))
    end
    empty!(mint.cache)
    nothing
end


"""
Receive all messages sent to process. Divides the messages based on the destination
vertex.
"""
function receive_messages!(mint::MessageInterface, w::Int=myid())
    vrange = get_local_vertices(mint::MessageInterface, w)
    vmq = [MessageAggregate() for i in vrange]
    for mbox in mint.mgrid[:,w]
        while isready(mbox)
            ma::MessageAggregate = take!(mbox)
            for m::Message in ma
                target_vertex = get_dest(m)-start(vrange)+1
                push!(vmq[target_vertex], m)
            end
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
