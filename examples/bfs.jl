####
##  Basic demonstration of Bulk Synchronous Parallel processing. These examples
## execute BFS on different input data sets.
####

# Number of worker processes
addprocs(2)

using BSP
# Unfortunately this is required to avoid using the prefix BSP.*
@everywhere importall BSP

# Define visitorFunction in all worker processes. Again need to fix this.
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


# Basic example that uses a adjacency matrix.
println("Example 1: 8 vertices")
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

# LightGraphs isn't supported yet. So convert graph into adjacency matrix
using LightGraphs

function getMatrix(g)
    n = length(vertices(g))
    m = zeros(Int, n, n)
    for (u,v) in edges(g)
        m[u,v] = 1
        m[v,u] = 1
    end
    m
end


# Slightly larger example. Requires LightGraphs.jl. Cross examines result with
# LightGraphs's single process BFS.
println("Example 2: 100 vertices")
g = random_regular_graph(100,50)
m = getMatrix(g)
sm = sparse(m)
node = bsp(visitorFunction,1,sm)
@time dans = compute(Context(), node)
ans = LightGraphs.gdistances!(g, 1, Array{Int,1}(100))
println("Did the two answers match?", dans == ans)

# Massive(somewhat) graph.
println("Example 3: 10000 vertices")
g = random_regular_graph(10000,1000)
m = getMatrix(g)
sm = sparse(m)
node = bsp(visitorFunction,1,sm)
@time dans = compute(Context(), node)
ans = LightGraphs.gdistances!(g, 1, Array{Int,1}(10000))
println("Did the two answers match?", dans == ans)
