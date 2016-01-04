"""
# Message Passing between processes.
An interface for passing messages between ALL processes including the main process.
Message Passing has to be separated from the ParallelGraphs implementation to simplify
the development of algorithms. Therefore the following interface is offered.
- `mint_init(nv)` : Create a message passsing interface for `nv` vertices.
- `send_message(_mint, targetVertex, message)` : Send a message to a vertex.
- `transmit(_mint)` : Redistribute messages.
- `receive_messages(_mint, w)` : Recieve all messages sent to a worker. Returns a MessageQueueList
"""

type MessageInterface
    ctx                  # Context
    dmgrid               # Distrbitued Message Grid
    vdist::Vector{Int}   # Vertex to worker Map
    wdist::Vector{UnitRange{Int}} # Worker to vertex map
end

"""Generate a matrix of MessageQueues and distribute it among ALL PROCESSES."""
function get_dmgrid(ctx)
    compute(ctx, distribute(generate_mgrid(length(procs()))))
end

"""Generate an array containing the parent process for each vertex."""
function get_vdist(nv, w)
    w > nv && (w = nv)
    starts = round(Int, linspace(1, nv+1, w+1))
    vdist = Vector{Int}()
    for i in 2:length(starts)
        vdist = vcat(vdist, fill(i, length(starts[i-1]:starts[i])-1))
    end
    vdist
end

"""Generate an array containing the range of vertices for each worker. """
function get_wdist(nv, w)
    wdist = UnitRange{Int}[0:0 for i in 1:(w+1)]
    w > nv && (w = nv)
    starts = round(Int, linspace(1, nv+1, w+1))
    for i in 2:length(starts)
        wdist[i] = starts[i-1]:(starts[i]-1)
    end
    wdist
end

"""
Initialize the message passing interface. Should be called only from the main
process. Calling this will reset the messaging interface as well.(Very messy).
"""
function mint_init(nv::Int)
    @assert myid() == 1
    w = length(workers())
    ctx = Context(procs())

    dmgrid = get_dmgrid(ctx)
    vdist = get_vdist(nv, w)
    wdist = get_wdist(nv, w)

    MessageInterface(ctx, dmgrid, vdist, wdist)
end

"""Get the parent process of a vertex. (Called from worker process)"""
function get_parent(mint::MessageInterface, v::Int)
    mint.vdist[v]
end

"""Get a worker's local vertices"""
function get_local_vertices(mint::MessageInterface, w::Int=myid())
    mint.wdist[w]
end

"""Get a process's message list."""
function get_message_queue_list(mint::MessageInterface, w::Int=myid())
    take!(mint.dmgrid.refs[w][2])
end

"""Set a process's message list"""
function set_message_queue_list(mint::MessageInterface, mlist::MessageQueueGrid, w::Int = myid())
    put!(mint.dmgrid.refs[w][2], mlist)
    nothing
end

""" Send a message to the target vertex """
function send_message(mint::MessageInterface, m::Message)
    mlist = get_message_queue_list(mint)
    target_proc = get_parent(mint, get_dest(m))
    push!(mlist[target_proc], m)
    set_message_queue_list(mint, mlist)
    nothing
end

""" Redistribute messages. (Should be called only in the main process)"""
function transmit(mint::MessageInterface)
    new_layout = mint.dmgrid.layout == cutdim(2)? cutdim(1) : cutdim(2)
    mint.dmgrid = compute(mint.ctx, redistribute(mint.dmgrid, new_layout))
    nothing
end

"""Receive all messages sent to process."""
function receive_messages(mint::MessageInterface, w::Int=myid())
    vrange = get_local_vertices(mint::MessageInterface, w)
    vmq = generate_mlist(length(vrange))
    mlist = get_message_queue_list(mint, w)
    for mq in mlist
        for m in mq
            push!(vmq[get_dest(m)-start(vrange)+1], m)
        end
        empty!(mq)
    end
    # set the empty mlist
    set_message_queue_list(mint, mlist, w)
    vmq
end
