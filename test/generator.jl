################################################# FILE DESCRIPTION #########################################################

# This file contains tests for graph generators

############################################################################################################################

@testset "Empty Graph tests" begin
   for AM in subtypes(AdjacencyModule), PM in subtypes(PropertyModule), typ in [Any,TestType]
      gtype = Graph{AM,PM{typ,typ}}
      introduce("$gtype")

      g = emptygraph(gtype, 10)
      @test nv(g) == 10
      @test ne(g) == 0
      @test isempty(edges(g))

      tick()
   end

   @test isa(emptygraph(10).adjmod, SparseMatrixAM)
end

@testset "Rand Graph tests" begin
   for AM in subtypes(AdjacencyModule), PM in subtypes(PropertyModule), typ in [Any,TestType]
      gtype = Graph{AM,PM{typ,typ}}
      introduce("$gtype")

      g = randgraph(gtype, 10, 20)
      @test nv(g) == 10
      # Can't test on exact number of edges

      tick()
   end

   @test isa(randgraph(10, 20).adjmod, SparseMatrixAM)
   @test nv(randgraph(10)) == 10
end

@testset "Complete Graph tests" begin
   for AM in subtypes(AdjacencyModule), PM in subtypes(PropertyModule), typ in [Any,TestType]
      gtype = Graph{AM,PM{typ,typ}}
      introduce("$gtype")

      g = completegraph(gtype, 10)
      @test nv(g) == 10
      # Can't test on exact number of edges

      tick()
   end

   @test isa(completegraph(10).adjmod, SparseMatrixAM)
end
