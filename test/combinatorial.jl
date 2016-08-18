################################################# FILE DESCRIPTION #########################################################

# This file contains tests for the Combinatorial API

############################################################################################################################


@testset "Combinatorial " begin
   g = completegraph(10)

   @test nv(g) == 10
   @test ne(g) == 90
   @test size(g) == (10,90)

   @test vertices(g) == 1 : 10

   @test hasvertex(g, rand(1:10))
   @test all(hasvertex(g, rand(1:10, 4)))

   @test hasedge(g, 1=>2)
   @test all(hasedge(g, edges(g)))

   @test fadj(g, 1) == collect(2:10)
   @test fadj!(g, 10, zeros(Int, 9)) == collect(1:9)

   @test outdegree(g, rand(1:10)) == 9
   @test outdegree(g, [1,2,3]) == [9,9,9]
   @test outdegree(g) == fill(9, 10)

   @test indegree(g, rand(1:10)) == 9
   @test indegree(g, [1,2,3]) == [9,9,9]
   @test indegree(g) == fill(9, 10)
   
   v = rand(vertices(g))
   @test g[v] == fadj(g, v)
end
