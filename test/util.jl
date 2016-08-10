################################################# FILE DESCRIPTION #########################################################

# This file contains tests for utils

############################################################################################################################

@testset "Type Aliases" begin
   @test VertexID == Int
   @test EdgeID == Pair{Int,Int}
   @test VertexList == AbstractVector{Int}
   @test EdgeList == AbstractVector{Pair{Int,Int}}

   @test isa(EdgeID[1=>2, 3=>4], EdgeList)
end
