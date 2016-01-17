nv = 10
density = 0.5

matrix = rand_graph(nv, density)

# To list
@test typeof(to_list(matrix)) <: AdjacencyList
list = to_list(matrix)
for iter in eachindex(list)
    @test get_adj(list, iter) == get_adj(matrix, iter)
end

# To matrix
@test typeof(to_matrix(list)) <: AdjacencyMatrix
matrix = to_matrix(list)
for iter in eachindex(list)
    @test get_adj(matrix, iter) == get_adj(list, iter)
end
