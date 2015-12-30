import ComputeFramework: Context, distribute, compute

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

function bsp_iterate(visitor::Function, graph::DistGraph, aux::AuxStruct)
    for w in workers() .- 1
        for m in getmlist(aux)[w]
            process_message(m, aux)
        end
    end
    setmlist(aux, generate_mlist(length(workers)))
    for i in find(active)
        visitor(graph, aux)
    end
    aux
end
