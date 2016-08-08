################################################# FILE DESCRIPTION #########################################################

# This file contains tests for parse

############################################################################################################################

@testset "GraphIO" begin
   g = loadgraph("testgraph.txt")
   @test nv(g) == 10
   @test ne(g) == 28

   @test encode(g) == collect(1 : 10)

   @test names(g.vdata) == [:name, :age]
   @test eltypes(g.vdata) == [Nullable{String}, Nullable{Int}]
   @test size(g.vdata) == (10, 2)

   @test names(g.edata) == [:relationship]
   @test eltypes(g.edata) == [Nullable{String}]
   @test size(g.edata) == (28,1)
end
