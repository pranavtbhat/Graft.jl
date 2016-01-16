addprocs(2)
using ParallelGraphs

gstruct = rand_graph(10, 0.2)
println(to_list(gstruct))
println(connected_components(gstruct))
