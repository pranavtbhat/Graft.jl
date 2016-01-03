@everywhere type TestAux <: BSP.AuxStruct
    v::Int
end

nv = 10
adj_list = Vector{Int}[round(Int, rand(nv)) for i in 1:nv]
adj_matrix = round(Int, rand(nv,nv))

# Test DistGraph{AdjacencyList}
list_graph = BSP.distgraph(adj_list)
@test BSP.get_vertices(list_graph) == collect(1:nv)
@test BSP.get_adj(list_graph) == adj_list
@test BSP.has_aux(list_graph) == false

aux_array = TestAux[TestAux(i) for i in 1:nv]
@test BSP.set_aux!(list_graph, aux_array) == nothing
@test BSP.has_aux(list_graph) == true
@test BSP.get_aux(list_graph) == aux_array
@test BSP.take_aux!(list_graph) == aux_array
@test BSP.has_aux(list_graph) == false

# Test DistGraph{AdjacencyMatrix}
matrix_graph = BSP.distgraph(adj_matrix)
@test BSP.get_vertices(matrix_graph) == collect(1:nv)
@test BSP.get_adj(matrix_graph) == adj_matrix
@test BSP.has_aux(matrix_graph) == false

aux_array = TestAux[TestAux(i) for i in 1:nv]
@test BSP.set_aux!(matrix_graph, aux_array) == nothing
@test BSP.has_aux(matrix_graph) == true
@test BSP.get_aux(matrix_graph) == aux_array
@test BSP.take_aux!(matrix_graph) == aux_array
@test BSP.has_aux(matrix_graph) == false

# Distribute DistGraph{AdjacencyList}
dg = compute(Context(), distribute(list_graph))
g = gather(Context(), dg)
@test isequal(g, list_graph)

# Distribute DistGraph{AdjacencyMatrix}
dg = compute(Context(), distribute(matrix_graph))
g = gather(Context(), dg)
@test isequal(g, matrix_graph)
