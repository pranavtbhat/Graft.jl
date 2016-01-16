import ComputeFramework.domain

"""Allow Bcast distribution of Functions"""
domain(::Function) = 1

"""Allow Bcast distribution of MessageInterface"""
domain(::ParallelGraphs.MessageInterface) = 1

"""
Bulk Synchronous Parallel processing. Executes synchronized iterations of the
input function. This function requires the following arguments:
- ctx: ComputeFramework context indicating worker processes.
- vlist: A list of vertices.
- gstruct: A graph structure of type GraphStruct.
- data: Auxiliary data required for some algorithms. Can be left empty.
"""
function bsp(visitor::Function, vlist::Vector, gstruct::GraphStruct, data...)
    visitors = compute(Context(), distribute(visitor, Bcast()))
    dvlist = compute(Context(), distribute(vlist))
    dgstruct = compute(Context(), distribute(gstruct))

    meta = reduce(vcat, UnitRange{Int}[], metadata(dvlist))
    mint = message_interface(meta)


    ddata = map(distribute, data)
    while true
        dmint = compute(Context(), distribute(mint, Bcast()))
        dvlist = compute(Context(), mappart(bsp_iterate, visitors, dvlist, dgstruct, dmint, ddata...))

        # Recover message interface
        mint = gather(Context(), dmint)

        # Synchronously transmit messages
        transmit!(mint)

        # Extract main process's message interface
        messages = receive_messages!(mint)[1]
        num_active = mapreduce(get_num_active, +, 0, messages)
        println("Num active-> ", num_active)
        num_active == 0 && break
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
    messages = receive_messages!(mint)
    for iter in eachindex(vlist)
        v = vlist[iter]
        adj = get_adj(gstruct, iter)
        mq = messages[iter]

        # Skip vertex if its inactive and has no messages addressed to it.
        !is_active(v) && isempty(mq) && continue
        # Execute the visitor function on the vertex.
        vlist[iter] = visitor(v, adj, mint, mq, map(x->x[iter], data)...)
    end
    # Count the number of active vertices
    num_active = mapreduce(is_active, +, 0, vlist)
    # Send the number of active vertices to the main process
    send_message!(mint, NumActive(num_active))

    vlist
end
