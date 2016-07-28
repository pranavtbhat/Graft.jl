################################################# FILE DESCRIPTION #########################################################

# This file contains tests for Adjacency Modules.

############################################################################################################################


for AM in subtypes(AdjacencyModule)
   @testset "AdjacencyModule interface for $AM" begin
      x = AM(10, 90)

      @test nv(x) == 10
      @test ne(x) == 90
      @test size(x) == (10,90)
      @test vertices(x) == 1 : 10

      @test all(e->hasedge(x, e), edges(x))

      @test fadj(x, 1) == collect(2:10)
      @test badj(x, 10) == collect(1:9)

      addvertex!(x)
      addvertex!(x)
      @test nv(x) == 12

      @test addedge!(x, 10, 11) == true
      @test addedge!(x, 10, 11) == false
      
      @test addedge!(x, [EdgeID(10, 12), EdgeID(11, 12)]) == nothing
      @test ne(x) == 93

      @test rmedge!(x, 11, 12) == nothing
      @test rmedge!(x, [EdgeID(10, 12), EdgeID(10, 11)]) == nothing
      @test ne(x) == 90

      @test rmvertex!(x, [11, 12]) == nothing
      @test rmvertex!(x, 10) == nothing
      @test nv(x) == 9
      @test ne(x) == 72
   end
end

# Edge Iteration

for AM in subtypes(AdjacencyModule)
   @testset "Edge iteration interface for $AM" begin
      x = AM(10, 90)
      eit = edges(x)
      es = collect(eit)

      @test [e for e in eit] == es

      @test all(eit .== es)
   end
end
