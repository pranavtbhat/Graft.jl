addprocs(2)
using ParallelGraphs

gstruct = rand_graph(100000, 0.00003)

@time bfs(gstruct)
