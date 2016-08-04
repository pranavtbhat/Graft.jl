################################################# FILE DESCRIPTION #########################################################

# This file contains tests for utils

############################################################################################################################

@testset "Type Aliases" begin

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

   x1 = getindex(x, 21:50)
   @test length(x1) == 30

   @test getindex(x, :) == x
end
