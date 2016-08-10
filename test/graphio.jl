################################################# FILE DESCRIPTION #########################################################

# This file contains tests for parse

############################################################################################################################

@testset "GraphIO" begin
   ###
   # loadgraph
   ###
   g = loadgraph("testgraph.txt")
   @test nv(g) == 10
   @test ne(g) == 28

   @test encode(g) == collect(1 : 10)

   @test names(g.vdata) == [:name, :age]
   @test eltypes(g.vdata) == [String, Int]
   @test size(g.vdata) == (10, 2)

   @test names(g.edata) == [:relationship]
   @test eltypes(g.edata) == [String]
   @test size(g.edata) == (28,1)

   ###
   # storegraph
   ###
   g = completegraph(10)
   # Vertex Properties
   setvprop!(g, :, rand(Int, 10), :p1)
   setvprop!(g, :, rand(10), :p2)
   setvprop!(g, :, [randstring() for i in 1:10], :p3)
   setvprop!(g, :, rand(Bool, 10), :p4)
   setvprop!(g, :, rand(Char, 10), :p5)

   # Edge properties
   seteprop!(g, :, rand(Int,90), :p1)
   seteprop!(g, :, rand(90), :p2)
   seteprop!(g, :, [randstring() for i in 1:90], :p3)
   seteprop!(g, :, rand(Bool, 90), :p4)
   seteprop!(g, :, rand(Char, 90), :p5)

   storegraph(g, "tmp.txt")

   h = loadgraph("tmp.txt")

   @test isequal(g, h)

   rm("tmp.txt")
end
