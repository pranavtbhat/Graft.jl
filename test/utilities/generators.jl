nv = 10
density = 0.5

# complete_graph
@test sum(complete_graph(nv)) == nv^2

# rand_graph
m = rand_graph(nv, density)::AdjacencyMatrix
@test m == m'

# rand_digraph
m = rand_digraph(nv, density)::AdjacencyMatrix
