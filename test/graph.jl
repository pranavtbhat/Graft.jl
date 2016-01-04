@everywhere type TestAux <: BSP.AuxStruct
    active::Bool
    v::Int
end

nv = 10
adj_list = Vector{Int}[round(Int, rand(nv)) for i in 1:nv]
adj_matrix = round(Int, rand(nv,nv))

function test_graph_representation(graph)
    aux_array = TestAux[TestAux(true, i) for i in 1:nv]
    # Test core accessors
    @test BSP.get_vertices(list_graph) == collect(1:nv)
    @test BSP.get_adj(list_graph) == adj_list

    # Test auxiliary accessors
    @test BSP.has_aux(list_graph) == false
    @test BSP.set_aux!(list_graph, aux_array) == nothing
    @test BSP.has_aux(list_graph) == true
    @test BSP.get_aux(list_graph) == aux_array

    # Test status accessors
    @test BSP.is_active(list_graph, rand(1:nv)) == true
    @test BSP.get_num_active(list_graph) == nv

    # Test auxiliary accessors again
    @test BSP.take_aux!(list_graph) == aux_array
    @test BSP.has_aux(list_graph) == false
end

# Test AdjacencyList graphs
list_graph = BSP.distgraph(adj_list)
test_graph_representation(list_graph)

# Test AdjacencyMatrix graphs
matrix_graph = BSP.distgraph(adj_matrix)
test_graph_representation(matrix_graph)

# Distribute DistGraph{AdjacencyList}
dg = compute(Context(), distribute(list_graph))
g = gather(Context(), dg)
@test isequal(g, list_graph)

# Distribute DistGraph{AdjacencyMatrix}
dg = compute(Context(), distribute(matrix_graph))
g = gather(Context(), dg)
@test isequal(g, matrix_graph)
