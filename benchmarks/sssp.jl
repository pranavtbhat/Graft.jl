using ParallelGraphs

g = rwgraph(10^6, 3 * 10^6, 50);
@time pv, dists = sssp(g, rand(1:10^6))
