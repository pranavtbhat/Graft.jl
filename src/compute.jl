import ComputeFramework: Context, distribute, compute, Bcast, mappart

"""
Bulk Synchronous Parallel processing. Applies iterations of Super Steps on
the input graph and auxiliary structure.
"""
function bsp{S}(ctx, visitor::Function, graph::DistGraph{S})
    visitors = compute(ctx, distribute(visitor, Bcast()))
    dgraph = compute(ctx, distribute(graph))
    mint_init(get_num_vertices(graph))
    for i in 1:2
        dgraph = mappart(bsp_iterate, visitors, dgraph)
        transmit()
    end
    # Fetch the array of processed graphs and combine it.
    gather(ctx, get_layout(graph), gather(ctx, dgraph))
end

"""
Bulk Synchronous Parallel iterations. Sorts out incoming messages and runs
the visitor function on each active vertex.
"""
function bsp_iterate(visitor::Function, graph::Any)
    println(fetch(graph))
    messages = receive_messages()
    for iter in eachindex(get_vertices(graph))
        isempty(messages[iter]) && !is_active(graph, iter) && continue  # Skip vertex if its inactive and has no messages addressed to it.
        visitor(get_vertices(graph)[iter], get_adj(get_struct(graph), iter), get_aux(graph)[iter], messages[iter])
    end
    graph
end
