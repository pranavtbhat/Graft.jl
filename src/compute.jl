function compute(ctx, node::BSPNode)
    n, = size(node.graph)
    n_workers = length(workers())

    ### Partition vertices(based on index_splits in layout.jl)
    vranges = getRanges(n, n_workers)
    dvranges = compute(ctx, distribute(vranges))

    ### Distribute graph and auxillaries ###
    dgraph = compute(ctx, distribute(node.graph))

    active = falses(n)
    active[node.seed] = true
    dactive = compute(ctx, distribute(active))

    ### Load dists, change to general data later
    dists = fill!(zeros(Int,n), -1)
    dists[node.seed] = 0
    ddists = compute(ctx, distribute(dists))

    # load and distribute message grid
    # the i,jth element represents the aggregation of messages
    # sent by the ith worker to the jth worker.
    MQ = generateMQ(n_workers)
    dMQ = compute(ctx, distribute(MQ))

    while true
        task = map(bspIteration, dvranges, dactive, dgraph, dMQ, ddists)
        result = gather(Context(), task)
        println(result)
    end
end

### Function to run a single iteration ###
function bspIteration(vrange, active, graph, MQ, ddists)
    n, = size(graph)

    # Process incoming messages
    for source in workers()
        for message::Message in MQ[source]
            processMessage(vrange, active, message)
        end
        empty!(MQ[source])
    end

    # Compute phase
    for i in find(active)
        u = getVertex(vrange, i)
        for v in find(graph[:,i])
            visitorFunction(v, vrange, active, graph, MQ, ddists)
        end
        active[i] = false
    end

    # return the number of active vertices at the end of the iteration.
    length(find(active))
end
