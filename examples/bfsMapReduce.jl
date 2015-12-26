
addprocs(2)

# Map function for BFS. Returns all vertices reachable from the input vertex
@everywhere function mapBFS(t)
  u = t[1]
  d = t[2]
  [(v,d+1) for v::Int in find(sparseMatrix[u,:])]
end

# Filter function for BFS. Discard already-explored vertices
@everywhere function filterBFS(tuple)
  u,d = tuple
  if dist[u] < 0
    dist[u] = d
    return true
  else
    return false
  end
end

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


println("Example: 1000 vertices")

numVertices = 1000
g = random_regular_graph(numVertices,round(Int,numVertices/10))
m = getMatrix(g)
sm = sparse(m)
@everywhere sparseMatrix = nothing
for p in procs()
    @spawnat p (global sparseMatrix; sparseMatrix = sm)
end
yield()

#place distance vector in shared memory and initialize it in parallel.
ldist = SharedArray(Int, numVertices, init = dist -> dist[Base.localindexes(dist)] = -1)
@everywhere dist = nothing
for p in procs()
  @spawnat p (global dist;dist = ldist)
end
yield()

# We could also use multiple seeds
dist[1] = 0
seedVertex = 1
Q = [(seedVertex,0)]

using ComputeFramework
# Main BFS loop that implements iterative map-reduce-filter
@time while length(Q) > 0
  s1 = map(mapBFS, distribute(Q))    # explore new vertices
  s2 = reduce(vcat, [], s1)          # concatenate the lists of tuples produced in map stage
  s3 = compute(Context(), s2)
  Q = gather(Context(), filter(filterBFS, distribute(s3)))
  println("Iteration complete")
end

println(dist)
