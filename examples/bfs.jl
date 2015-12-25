addprocs(2)

using BSP
@everywhere importall BSP


@everywhere function visitorFunction(i, vrange, active, graph, MQ, dists)
    n, = size(graph)
    for v in find(graph[:,i])
        j = getLocalIndex(vrange, v)
        parent_proc = getParentProc(n, v)

        i == j && continue

        if parent_proc == myid()
            dists[j] < 0 || continue
            active[j] = true
            dists[j] = dists[i] + 1
        else
            push!(MQ[parent_proc-1], ActivateMessage(v,dists[i]+1))
        end
    end
end

m = [ 0  1  1  1  0  0  0  0;
      1  0  1  0  1  1  0  0;
      1  1  0  1  0  1  1  0;
      1  0  1  0  0  0  1  0;
      0  1  0  0  0  1  0  1;
      0  1  1  0  1  0  1  1;
      0  0  1  1  0  1  0  1;
      0  0  0  0  1  1  1  0;
    ]
sm = sparse(m)
node = bsp(visitorFunction, 1, sm)
println(compute(Context(), node))
