addprocs(2)
using ParallelGraphs

gstruct = rand_graph(1000000, 0.000003)

@time connected_components(gstruct)
