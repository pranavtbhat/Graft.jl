################################################# FILE DESCRIPTION #########################################################

# This file contains tests for Adjacency Modules.
 
############################################################################################################################


for amtype in subtypes(AdjacencyModule)
   g = parsegraph("testgraph.txt", :TGF, Graph{amtype,NullModule})
   am = ParallelGraphs.adjmod(g)

   @testset "AdjacencyModule interface for $amtype" begin
      @test nv(am) == 10
      @test ne(am) == 28
      @test size(am) == (10, 28)
      @test fadj(am, 1) == [2, 3]
      @test fadj(am, 4) == [3, 5, 6, 7, 8, 9, 10]
      @test badj(am, 3) == [1, 2, 4]
      @test badj(am, 10) == [4, 9]
      @test addvertex!(am) == nothing
      @test nv(am) == 11
      @test addedge!(am, 10, 11) == nothing
      @test ne(am) == 29
      @test rmedge!(am, 10, 11) == nothing
      @test ne(am) == 28
      @test rmvertex!(am, 11) == nothing
      @test nv(am) == 10
   end
end