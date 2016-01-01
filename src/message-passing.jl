import ComputeFramework: complement
###
# This file contains a message pasing interface. It uses a global variable and is Therefore
# likely to be messy and slow :(
###

"""
# Message Passing between processes.
An interface for passing messages between ALL processes including the main process.
Message Passing has to be separated from the BSP implementation to simplify
the development of algorithms. Therefore the following interface is offered.
- `mint_init(nv)` : Initialize the message passsing interface for `nv` vertices.
- `send_message(targetVertex, message)` : Send a message to a vertex.
- `transmit()` : Redistribute messages.
- `receive_messages(w)` : Recieve all messages sent to a worker. Returns a MessageQueueList
"""

type MessageInterface
    ctx                  # Context
    dmgrid               # Distrbitued Message Grid
    vdist::Vector{Int}   # Vertex to worker Map
    wdist::Vector{UnitRange{Int}} # Worker to vertex map
end

"""Global Variable to hold the MessageInterface. (May cause performance problems)"""
const _mint = MessageInterface(nothing, nothing, Vector{Int}(), Vector{UnitRange{Int}}())

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

    for p in procs()
        @spawnat p (
            global _mint;
            _mint.ctx = ctx;
            _mint.dmgrid = dmgrid;
            _mint.vdist = vdist;
            _mint.wdist = wdist
            )
    end
    nothing
end

"""Get the parent process of a vertex. (Called from worker process)"""
function get_parent(v::Int)
    _mint.vdist[v]
end

"""Get a worker's local vertices"""
function get_local_vertices(w::Int=myid())
    _mint.wdist[w]
end

"""Get a process's message list."""
function get_message_queue_list(w::Int=myid())
    take!(_mint.dmgrid.refs[w][2])
end

"""Set a process's message list"""
function get_message_queue_list(mlist::MessageQueueGrid, w::Int = myid())
    put!(_mint.dmgrid.refs[w][2], mlist)
    nothing
end

""" Send a message to the target vertex """
function send_message(m::Message)
    mlist = get_message_queue_list()
    push!(mlist[get_parent(dest(m))], m)
    get_message_queue_list(mlist)
    nothing
end

""" Redistribute messages. (Should be called only in the main process)"""
function transmit()
    new_layout = _mint.dmgrid.layout == cutdim(2)? cutdim(1) : cutdim(2)
    dmgrid = compute(_mint.ctx, redistribute(_mint.dmgrid, new_layout))
    for p in procs()
        @spawnat p (global _mint;_mint.dmgrid = dmgrid)
    end
    nothing
end

"""Receive all messages sent to process."""
function receive_messages(w::Int=myid())
    vrange = get_local_vertices(w)
    vmq = generate_mlist(length(vrange))
    mlist = get_message_queue_list(w)
    for mq in mlist
        for m in mq
            push!(vmq[dest(m)-start(vrange)+1], m)
        end
        empty!(mq)
    end
    # set the empty mlist
    get_message_queue_list(mlist, w)
    vmq
end
