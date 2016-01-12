"""
Bulk Synchronous Parallel processing. Executes synchronized iterations of the
input function. This function requires the following arguments:
- ctx: ComputeFramework context indicating worker processes.
- vlist: A list of vertices.
- gstruct: A graph structure of type GraphStruct.
- data: Auxiliary data required for some algorithms. Can be left empty.
"""
function bsp(ctx, visitor::Function, vlist::Vector{Vertex}, gstruct::GraphStruct, data...)
    visitors = distribute(visitor, Bcast())
    dvlist = distribute(vlist)
    dgstruct = distribute(gstruct)
    dmint = distribute(message_interface(metadata(dvlist)), Bcast())
    ddata = map(distribute, data)
    while true
        dvlist = mappart(bsp_iterate, visitors, dvlist, dgstruct, dmint, ddata...)
        transmit!(mint)
    end
    gather(ctx, dvlist)
end

"""
A series of super-steps. Sorts out incoming messages and runs
the visitor function on each active vertex. This function requires the following arguments:
- visitor: The vertex visitor function.
- mint: MessageInterface required for message passing.
- vlist: List of local vertices
- data: Auxiliary data required for some algorithms. Can be empty.
"""
function bsp_iterate(visitor::Function, mint::MessageInterface, vlist::Vector{Vertex}, gstruct, data...)
    messages = receive_messages(mint)
    for iter in eachindex(vlist, gstruct, messages)
        v = vlist[iter]
        adj = get_adj(gstruct, iter)
        mq = messages[iter]

        # Skip vertex if its inactive and has no messages addressed to it.
        !is_active(v) && isempty(mq) && continue
        # Execute the visitor function on the vertex.
        vlist[iter] = visitor(v, adj, mint, mq, map(x->x[iter], data)...)
    end
    vlist
end
