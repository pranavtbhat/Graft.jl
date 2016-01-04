@everywhere type TestAux <: ParallelGraphs.AuxStruct
    active::Bool
    v::Int
end

nv = 10
adj_list = Vector{Int}[round(Int, rand(nv)) for i in 1:nv]
adj_matrix = round(Int, rand(nv,nv))

function test_graph_representation(graph)
    aux_array = TestAux[TestAux(true, i) for i in 1:nv]
    # Test core accessors
    @test ParallelGraphs.get_vertices(list_graph) == collect(1:nv)
    @test ParallelGraphs.get_adj(list_graph) == adj_list

    # Test auxiliary accessors
    @test ParallelGraphs.has_aux(list_graph) == false
    @test ParallelGraphs.set_aux!(list_graph, aux_array) == nothing
    @test ParallelGraphs.has_aux(list_graph) == true
    @test ParallelGraphs.get_aux(list_graph) == aux_array

    # Test status accessors
    @test ParallelGraphs.is_active(list_graph, rand(1:nv)) == true
    @test ParallelGraphs.get_num_active(list_graph) == nv

    # Test auxiliary accessors again
    @test ParallelGraphs.take_aux!(list_graph) == aux_array
    @test ParallelGraphs.has_aux(list_graph) == false
end

# Test AdjacencyList graphs
list_graph = ParallelGraphs.distgraph(adj_list)
test_graph_representation(list_graph)

# Test AdjacencyMatrix graphs
matrix_graph = ParallelGraphs.distgraph(adj_matrix)
test_graph_representation(matrix_graph)

# Distribute DistGraph{AdjacencyList}
dg = compute(Context(), distribute(list_graph))
g = gather(Context(), dg)
@test isequal(g, list_graph)

# Distribute DistGraph{AdjacencyMatrix}
dg = compute(Context(), distribute(matrix_graph))
g = gather(Context(), dg)
@test isequal(g, matrix_graph)
