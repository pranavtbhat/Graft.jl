################################################# FILE DESCRIPTION #########################################################

# This file contains tests for Adjacency Modules.
 
############################################################################################################################


for amtype in subtypes(AdjacencyModule)
   g = parsegraph("testgraph.txt", :TGF, SimpleGraph)
   @testset "AdjacencyModule interface for $amtype" begin
      @test nv(g) == 10
      @test ne(g) == 28
      @test size(g) == (10, 28)
      @test fadj(g, 1) == [2, 3]
      @test fadj(g, 4) == [3, 5, 6, 7, 8, 9, 10]
      @test badj(g, 3) == [1, 2, 4]
      @test badj(g, 10) == [4, 9]
      @test addvertex!(g) == nothing
      @test nv(g) == 11
      @test addedge!(g, 10, 11) == nothing
      @test ne(g) == 29
      @test rmedge!(g, 10, 11) == nothing
      @test ne(g) == 28
      @test rmvertex!(g, 11) == nothing
      @test nv(g) == 10
   end
end