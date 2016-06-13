################################################# FILE DESCRIPTION #########################################################

# This file contains tests for Adjacency Modules.
 
############################################################################################################################


for AM in subtypes(AdjacencyModule)
   g = parsegraph("testgraph.txt", :TGF, Graph{AM,NullModule})
   @testset "AdjacencyModule interface for $AM" begin
      @test nv(g) == 10
      @test ne(g) == 28
      @test size(g) == (10, 28)
      @test vertices(g) == 1 : 10

      elist = []
      for e in edges(g)
         push!(elist, e)
      end
      @test length(elist) == 28
      @test sum([hasedge(g, e...) for e in elist]) == 28

      @test collect(fadj(g, 1)) == [2, 3]
      @test collect(fadj(g, 4)) == [3, 5, 6, 7, 8, 9, 10]
      
      @test collect(badj(g, 3)) == [1, 2, 4]
      @test collect(badj(g, 10)) == [4, 9]
      
      @test addvertex!(g) == nothing
      @test nv(g) == 11
      
      @test addedge!(g, 10, 11) == nothing
      @test ne(g) == 29
      
      @test rmedge!(g, 10, 11) == nothing
      @test ne(g) == 28
      
      @test rmvertex!(g, 11) == nothing
   end
end