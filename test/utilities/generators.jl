nv = 10
density = 0.5

# complete_graph
@test sum(complete_graph(nv)) == nv^2

# rand_graph
@test typeof(rand_graph(nv, density)) == AdjacencyMatrix
m = rand_graph(nv, density)
@test m == m'

# rand_digraph
@test typeof(rand_digraph(nv, density)) == AdjacencyMatrix
m = rand_graph(nv, density)
@test m == m'
