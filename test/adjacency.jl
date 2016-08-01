################################################# FILE DESCRIPTION #########################################################

# This file contains tests for Adjacency Modules.

############################################################################################################################


@testset "AdjacencyModule interface" begin
   for AM in subtypes(AdjacencyModule)
      introduce("$AM")
      g = completegraph(Graph{AM,LinearPM},10)

      @test nv(g) == 10
      @test ne(g) == 90
      @test size(g) == (10,90)
      @test vertices(g) == 1 : 10

      @test all(e->hasedge(g, e), edges(g))

      @test fadj(g, 1) == collect(2:10)
      @test badj(g, 10) == collect(1:9)

      addvertex!(g)
      addvertex!(g)
      @test nv(g) == 12

      @test addedge!(g, 10, 11) == true
      @test addedge!(g, 10, 11) == false

      addedge!(g, [EdgeID(10, 12), EdgeID(11, 12)])
      @test ne(g) == 93

      rmedge!(g, 11, 12)
      rmedge!(g, [EdgeID(10, 12), EdgeID(10, 11)])
      @test ne(g) == 90

      rmvertex!(g, [11, 12])
      rmvertex!(g, 10)

      @test nv(g) == 9
      @test ne(g) == 72

      tick()
   end
end

# Edge Iteration

@testset "Edge iteration interface" begin
   for AM in subtypes(AdjacencyModule)
      introduce("$AM")
      g = completegraph(Graph{AM,LinearPM},10)
      eit = edges(g)
      es = collect(eit)

      @test [e for e in eit] == es

      @test all(eit .== es)

      tick()
   end
end
