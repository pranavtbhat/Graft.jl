################################################# FILE DESCRIPTION #########################################################

# This file contains tests for graph generators

############################################################################################################################

@testset "Empty Graph tests" begin
   for AM in subtypes(AdjacencyModule), PM in subtypes(PropertyModule), typ in [Any,TestType]
      g = emptygraph(Graph{AM,PM{typ,typ}}, 10)
      @test nv(g) == 10
      @test ne(g) == 0
      @test isempty(edges(g))
   end

   @test isa(emptygraph(10).adjmod, SparseMatrixAM)
end

@testset "Rand Graph tests" begin
   for AM in subtypes(AdjacencyModule), PM in subtypes(PropertyModule), typ in [Any,TestType]
      g = randgraph(Graph{AM,PM{typ,typ}}, 10, 20)
      @test nv(g) == 10
      # Can't test on exact number of edges
   end

   @test isa(randgraph(10, 20).adjmod, SparseMatrixAM)
   @test nv(randgraph(10)) == 10
end

@testset "Complete Graph tests" begin
   for AM in subtypes(AdjacencyModule), PM in subtypes(PropertyModule), typ in [Any,TestType]
      g = completegraph(Graph{AM,PM{typ,typ}}, 10)
      @test nv(g) == 10
      # Can't test on exact number of edges
   end

   @test isa(completegraph(10).adjmod, SparseMatrixAM)
end
