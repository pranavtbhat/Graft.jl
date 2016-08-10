################################################# FILE DESCRIPTION #########################################################

# This file contains tests for graph generators

############################################################################################################################

@testset "Graph Generation" begin
   ls = map(string, 1:10)

   g1 = Graph(10)
   @test nv(g1) == 10
   @test ne(g1) == 0
   @test isempty(edges(g1))

   g2 = Graph(10, 20)
   @test nv(g2) == 10
   @test ne(g2) > 0

   g3 = Graph(10, ls)
   @test nv(g3) == 10
   @test ne(g3) == 0
   @test encode(g3) == ls

   g4 = Graph(10, ls, 20)
   @test nv(g4) == 10
   @test ne(g4) > 0
   @test encode(g4) == ls

   @test emptygraph(10) == g1

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
