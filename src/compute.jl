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
    # Distributions
    @time begin
        visitors = compute(Context(), distribute(visitor, Bcast()))
        dvlist = compute(Context(), distribute(vlist))
        dgstruct = compute(Context(), distribute(gstruct))

        meta = reduce(vcat, UnitRange{Int}[], metadata(dvlist))
        mint = message_interface(meta)

        ddata = map(distribute, data)
        dmint = compute(Context(), distribute(mint, Bcast()))
    end

    println()
    @time while true
        dvlist = compute(Context(), mappart(bsp_iterate, visitors, dvlist, dgstruct, dmint, ddata...))

        # Wait for all workers to finish
        @time barrier_wait(mint)

        # Recover message interface
        # @time mint = gather(Context(), dmint)

        # Extract main process's message interface
        messages = receive_messages!(mint)[1]
        # Throw any errors
        errors = filter(x->isa(x, ErrorMessage), messages)
        if !isempty(errors)
            error("Errors on worker processes:\n $(join(map(x->join([get_vertex(x),get_error(x)]," "), errors), "\n"))")
        end

        # count = 0
        # while(isready(mint.count))
        #     take!(mint.count)
        #     count += 1
        # end
        # println(count)
        # println("\n")

        # Compute the number of active vertices and stop execution if there exist none
        active_list = filter(x->isa(x, NumActive), messages)
        num_active = mapreduce(get_num_active, +, 0, active_list)
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

    # Wake up inactive vertices with incoming messages.
    for iter in eachindex(vlist, messages)
        v = vlist[iter]
        mq = messages[iter]
        !isempty(mq) && activate!(v)
    end

    # Count the number of active vertices
    num_active = mapreduce(is_active, +, 0, vlist)
    # Send the number of active vertices to the main process
    send_message!(mint, NumActive(num_active))
    # Process active vertices
    for iter in eachindex(vlist)
        v = vlist[iter]
        !is_active(v) && continue

        # Prepare data
        adj = get_adj(gstruct, iter)
        mq = messages[iter]
        vdata = map(x->x[iter], data)

        # Execute the visitor function on the vertex. Catch all errors possible
        vlist[iter] = try
            visitor(v, adj, mint, mq, vdata...)
        catch e
            send_message!(mint, ErrorMessage(e, vlist[iter]))
            vlist[iter]
        end
    end

    # Transmit cached messages
    transmit!(mint)

    # Signal end of worker's execution
    barrier_signal(mint)
    vlist
end
