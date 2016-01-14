"""
An interface for passing messages between ALL processes including the main process.
Message Passing has to be separated from the ParallelGraphs implementation to simplify
the development of algorithms. Therefore the following interface is offered.
- `message_interface(nv)` : Create a message passsing interface for `nv` vertices.
- `send_message(mint, targetVertex, message)` : Send a message to a vertex.
- `transmit(mint)` : Redistribute messages.
- `receive_messages(mint, w)` : Recieve all messages sent to a worker. Returns a MessageQueueList
"""
type MessageInterface
    ctx                  # Context.
    dmgrid               # Distrbitued Message Grid.
    metadata             # Vertex distribution metadata.
end

"""Generate a matrix of MessageQueues and distribute it."""
function get_dmgrid(ctx)
    lp = length(procs())
    compute(ctx, distribute(generate_mgrid(lp)))
end

"""
Initialize the message passing interface. Should be called only from the main
process.
"""
function message_interface(metadata)
    @assert myid() == 1
    ctx = Context(procs())
    dmgrid = get_dmgrid(ctx)
    metadata = reduce(vcat, UnitRange{Int}[], metadata)       # remove outer arrays
    unshift!(metadata, 0:0)                                   # main proc is assigned no vertices.
    MessageInterface(ctx, dmgrid, metadata)
end

"""Get the process to which the vertex has been assigned"""
function get_parent(mint::MessageInterface, v::Int)
    findfirst(x-> v in x, mint.metadata)
end

"""Get a worker's local vertices"""
function get_local_vertices(mint::MessageInterface, w::Int=myid())
    mint.metadata[w]
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
function send_message(mint::MessageInterface, m::Message, w=myid())
    mlist = get_message_queue_list(mint, w)
    target_proc = get_parent(mint, get_dest(m))
    push!(mlist[target_proc], m)
    set_message_queue_list(mint, mlist, w)
    nothing
end

""" Redistribute messages. (Should be called only in the main process)"""
function transmit(mint::MessageInterface)
    new_layout = mint.dmgrid.layout == cutdim(2)? cutdim(1) : cutdim(2)
    mint.dmgrid = compute(mint.ctx, redistribute(mint.dmgrid, new_layout))
    nothing
end

"""
Receive all messages sent to process. Divides the messages based on the destination
vertex.
"""
function receive_messages(mint::MessageInterface, w::Int=myid())
    vrange = get_local_vertices(mint::MessageInterface, w)
    vmq = generate_mlist(length(vrange))
    mlist = get_message_queue_list(mint, w)
    for mq in mlist
        for m::Message in mq
            push!(vmq[get_dest(m)-start(vrange)+1], m)
        end
        empty!(mq)
    end
    # set the empty mlist
    set_message_queue_list(mint, mlist, w)
    vmq
end
