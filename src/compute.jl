"""
Bulk Synchronous Parallel processing. Executes synchronized iterations of the
input function. This function requires the following arguments:
- ctx: ComputeFramework context indicating worker processes.
- vlist: A list of vertices.
- gstruct: A graph structure of type GraphStruct.
- data: Auxiliary data required for some algorithms. Can be left empty.
"""
function distribute_data(data)
    compute(Context(), distribute(data))
end

function bsp(visitor::Function, vlist::Vector, gstruct::GraphStruct, data...)
    visitors = compute(Context(), distribute(visitor, Bcast()))
    dvlist = compute(Context(), distribute(vlist))
    dgstruct = compute(Context(), distribute(gstruct))
    dmint = compute(Context(), distribute(message_interface(metadata(dvlist)), Bcast()))
    ddata = map(distribute_data, data)
    for i in 1:1
        dvlist = compute(Context(), mappart(bsp_iterate, visitors, dvlist, dgstruct, dmint, ddata...))
        # transmit!(mint)
    end
    gather(Context(), dvlist)
end

"""
A series of super-steps. Sorts out incoming messages and runs
the visitor function on each active vertex. This function requires the following arguments:
- visitor: The vertex visitor function.
- mint: MessageInterface required for message passing.
- vlist: List of local vertices
- data: Auxiliary data required for some algorithms. Can be empty.
"""
function bsp_iterate(visitor::Function, vlist::Vector, gstruct,  mint::MessageInterface, data...)
    messages = receive_messages(mint)
    for iter in eachindex(vlist)
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
