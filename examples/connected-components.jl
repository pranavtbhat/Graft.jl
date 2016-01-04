addprocs(2)
using ParallelGraphs

g = ParallelGraphs.distgraph(round(Int, rand(100,100)))
println(connected_components(g))
