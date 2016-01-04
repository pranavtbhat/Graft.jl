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
    @test ParallelGraphs.get_num_vertices(graph) == nv
    @test ParallelGraphs.get_vertices(graph) == collect(1:nv)

    # Test auxiliary accessors
    @test ParallelGraphs.has_aux(graph) == false
    @test ParallelGraphs.set_aux!(graph, aux_array) == nothing
    @test ParallelGraphs.has_aux(graph) == true
    @test ParallelGraphs.get_aux(graph) == aux_array

    # Test status accessors
    @test ParallelGraphs.is_active(graph, rand(1:nv)) == true
    @test ParallelGraphs.get_num_active(graph) == nv

    # Test auxiliary accessors again
    @test ParallelGraphs.take_aux!(graph) == aux_array
    @test ParallelGraphs.has_aux(graph) == false
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
