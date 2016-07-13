################################################# FILE DESCRIPTION #########################################################

# This file contains tests for Adjacency Modules.

############################################################################################################################


for AM in subtypes(AdjacencyModule)
   @testset "AdjacencyModule interface for $AM" begin
      g = Graph{AM,NullModule}(10, 90)
      @test nv(g) == 10
      @test ne(g) == 90
      @test size(g) == (10,90)
      @test vertices(g) == 1 : 10

      @test all(e->hasedge(g, e), edges(g))

      @test fadj(g, 1) == collect(2:10)
      @test badj(g, 10) == collect(1:9)

      @test addvertex!(g, 2) == nothing
      @test nv(g) == 12

      @test addedge!(g, 10, 11) == nothing
      @test addedge!(g, [EdgeID(10, 12), EdgeID(11, 12)]) == nothing
      @test ne(g) == 93

      @test rmedge!(g, 11, 12) == nothing
      @test rmedge!(g, [EdgeID(10, 12), EdgeID(10, 11)]) == nothing
      @test ne(g) == 90

      @test rmvertex!(g, [11, 12]) == nothing
      @test rmvertex!(g, 10) == nothing
      @test nv(g) == 9
      @test ne(g) == 72
   end
end

# Edge Iteration

for AM in subtypes(AdjacencyModule)
   @testset "Edge iteration interface for $AM" begin
      g = Graph{AM,NullModule}(10, 90)
      eit = edges(g)
      es = collect(eit)

      @test isa(eit, ParallelGraphs.EdgeIter)
      @test [e for e in eit] == es

      @test all(eit .== es)
   end
end
