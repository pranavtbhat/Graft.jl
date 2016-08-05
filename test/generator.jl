################################################# FILE DESCRIPTION #########################################################

# This file contains tests for graph generators

############################################################################################################################

@testset "Graph Generator" begin
   g = emptygraph(10)
   @test nv(g) == 10
   @test ne(g) == 0
   @test isempty(edges(g))

   g = randgraph(10, 20)
   @test nv(g) == 10
   @test ne(g) > 0

   g = randgraph(10)
   @test nv(g) == 10
   @test ne(g) > 0

   g = completegraph(10)
   @test nv(g) == 10
   @test ne(g) == 90
end
