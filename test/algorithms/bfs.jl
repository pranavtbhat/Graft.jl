addprocs(2)
using ParallelGraphs

nv = 10
g = rand_graph(10,0.5)
println(bfs(g))
