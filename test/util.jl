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

@testset "FakeVector" begin
   x = FakeVector(nothing, 100)

   @test length(x) == 100
   @test size(x) == (100,)

   @test eltype(x) == Void

   @test start(x) == 1
   @test next(x, 1) == (nothing, 2)
   @test done(x, 101) == true
   @test endof(x) == 100
   @test eachindex(x) == 1:100

   @test getindex(x, rand(1:100)) == nothing
   @test length(getindex(x, 21:50)) == 30
   @test getindex(x, :) == x

   try setindex!(x); @test false catch @test true end
end
