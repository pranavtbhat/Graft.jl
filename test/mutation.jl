################################################# FILE DESCRIPTION #########################################################

# This file contains tests for the Mutation API

############################################################################################################################

@testset "Mutation API" begin
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
end
