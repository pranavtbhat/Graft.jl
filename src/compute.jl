import ComputeFramework: Context, distribute, compute

"""
Bulk Synchronous Parallel processing. Applies iterations of Super Steps on
the input graph and auxiliary structure.
"""
function bsp(ctx, visitor::Function, graph::DistGraph)
    visitors = compute(ctx, distribute(visitor, Bcat()))
    dgraph = compute(ctx, distribute(graph))
    for i in 1:15
        dgraph = mappart(bsp_iterate, visitors, dgraph)
    end
    gather(ctx, daux)
end

"""
Bulk Synchronous Parallel iterations. Sorts out incoming messages and runs
the visitor function on each active vertex.
"""
function bsp_iterate(visitor::Function, graph::DistGraph)
    messages = receive_messages()
    for iter in eachindex(get_vertices(graph))
        isempty(messages[iter]) && is_active(graph, iter) && continue  # Skip vertex if its inactive and has no messages addressed to it.
        visitor(get_vertices(graph)[iter], get_adjacencies(graph, iter), get_aux(graph)[iter], messages[iter])
    end
    graph
end
