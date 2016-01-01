import ComputeFramework: Context, distribute, compute

"""
Bulk Synchronous Parallel processing. Applies iterations of Super Steps on
the input graph and auxiliary structure.
"""
function bsp(ctx, visitor::Function, graph::DistGraph, aux::AuxStruct)
    visitors = distribute(visitor, Bcat())
    dgraph = compute(ctx, distribute(graph))
    daux = compute(ctx, distribute(aux))
    for i in 1:15
        daux = mappart(bsp_iterate, visitors, dgraph, daux)
        dMQ = compute(ctx, distribute(gather(ctx, transpose(dMQ))))
    end
    gather(ctx, daux)
end

"""
Bulk Synchronous Parallel iterations. Sorts out incoming messages and runs
the visitor function on each active vertex.
"""
function bsp_iterate(visitor::Function, graph::DistGraph, aux::AuxStruct)
    messages = receive_messages()
    for i in eachindex(vertices(graph))
        visitor(i, graph, aux, messages)
    end
    aux
end
