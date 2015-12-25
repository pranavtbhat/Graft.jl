function getRemoteRef(node, wid)
    node.refs[wid-1][2]
end

function compute(ctx, node::BSPNode)
    n, = size(node.graph)
    n_workers = length(workers())

    ### Partition vertices(based on index_splits in layout.jl)
    vrange = getRanges(n, n_workers)
    dvrange = compute(ctx, distribute(vrange))

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

    for i in 1:10
        taskRefs = []
        # Iterate over workers
        println("--------------------------------------------------")
        for wid in workers()
            # Fetch RemoteRefs of distributed data
            lvrange = getRemoteRef(dvrange, wid)
            lactive = getRemoteRef(dactive, wid)
            lgraph = getRemoteRef(dgraph, wid)
            lMQ = getRemoteRef(dMQ, wid)
            ldists = getRemoteRef(ddists, wid)

            # Run remotecall
            push!(taskRefs, remotecall(wid, bspIteration, node.f, lvrange,
                                    lactive, lgraph, lMQ, ldists))
        end

        # Exit if 0 vertices are active
        num_active = mapreduce(fetch, +, 0, taskRefs)
        # num_active == 0 && break

        println("++++++++++++++++++++++++++++++++++++++++++++++++++")
        # Compute Transpose of MQ to move messages around
        dMQ = compute(ctx, distribute(gather(ctx, transpose(dMQ))))
    end
    gather(ctx, ddists)
end

### Function to run a single iteration ###
function bspIteration(visitorFunction, lvrange, lactive, lgraph, lMQ, ldists)
    # Load readonly inputs
    vrange = fetch(lvrange)[1]
    graph = fetch(lgraph)

    # consume writeable inputs
    active = take!(lactive)
    MQ = take!(lMQ)
    dists = take!(ldists)

    n, = size(graph)
    println("Active:",active)

    # Process incoming messages
    println("Incoming Messages:", MQ)
    for source in workers()
        for message::Message in getMessages(MQ[source-1])
            i = getLocalIndex(vrange, message.target)
            if dists[i] < 0
                active[i] = true
                dists[i] = message.data
            end
        end
        empty!(MQ[source-1])
    end

    # Compute phase
    for i in find(active)
        visitorFunction(i, vrange, active, graph, MQ, dists)
        active[i] = false
    end

    println("Outgoing Messages:", MQ)
    # write outputs to remote references
    put!(lactive, active)
    put!(lMQ, MQ)
    put!(ldists, dists)

    # return the number of active vertices at the end of the iteration.
    length(find(active))
end
