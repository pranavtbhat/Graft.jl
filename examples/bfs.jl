addprocs(2)

using BSP
@everywhere importall BSP


@everywhere function visitorFunction(i, vrange, active, graph, MQ, dists)
    n, = size(graph)
    for v in find(graph[:,i])
        j = getLocalIndex(vrange, v)
        i == j && continue

        parent_proc = getParentProc(n, v)
        if parent_proc == myid() && dists[j] < 0
            active[j] = true
            dists[j] = dists[i] + 1
        else
            push!(MQ[parent_proc-1], ActivateMessage(v))
        end
    end
end

m = sparse(ones(Int,10,10))
node = bsp(visitorFunction, 1, m)
println(compute(Context(), node))
