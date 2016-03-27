using ParallelGraphs

g = rgraph(10^6, 3 * 10^6);
@time pv = bfs(g, rand(1:10^6))
