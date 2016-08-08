################################################# FILE DESCRIPTION #########################################################

# This file contains tests for SubGraph operations.

############################################################################################################################

@testset "Subgraph" begin
   gtype = completegraph(10)

   g = Graph(completeindxs(10))
   eit = edges(g)

   # Set Labels
   ls = map(string, 1:10)
   setlabel!(g, ls)

   # Set vertex properties
   setvprop!(g, :, 1:10, :p1)
   setvprop!(g, :, 1:10, :p2)

   # Set edge properties
   seteprop!(g, :, 1:90, :p1)
   seteprop!(g, :, 1:90, :p2)

   g1 = subgraph(g)
   @test isequal(g1, g)

   g2 = subgraph(g, 1:5)
   @test nv(g2) == 5
   @test ne(g2) == 20
   @test names(vdata(g2)) == [:p1,:p2]
   @test size(vdata(g2)) == (5, 2)
   @test names(edata(g2)) == [:p1,:p2]
   @test size(edata(g2)) == (20, 2)
   @test encode(g2) == ls[1:5]

   g3 = subgraph(g, 1:7, [:p2])
   @test nv(g3) == 7
   @test ne(g3) == 42
   @test names(vdata(g3)) == [:p2]
   @test size(vdata(g3)) == (7, 1)
   @test names(edata(g3)) == [:p1,:p2]
   @test size(edata(g3)) == (42,2)
   @test encode(g3) == ls[1:7]

   es = eit[1:45]
   g4 = subgraph(g, es)
   @test nv(g4) == 10
   @test ne(g4) == 45
   @test names(vdata(g4)) == [:p1,:p2]
   @test size(vdata(g4)) == (10, 2)
   @test names(edata(g4)) == [:p1,:p2]
   @test size(edata(g4)) == (45, 2)
   @test encode(g4) == ls

   es = eit[35:70]
   g5 = subgraph(g, es, [:p1])
   @test nv(g5) == 10
   @test ne(g5) == 36
   @test names(vdata(g5)) == [:p1,:p2]
   @test size(vdata(g5)) == (10,2)
   @test names(edata(g5)) == [:p1]
   @test size(edata(g5)) == (36,1)
   @test encode(g5) == ls

   es = [1=>2, 2=>3, 3=>1]
   g6 = subgraph(g, 1:3, es)
   @test nv(g6) == 3
   @test ne(g6) == 3
   @test encode(g6) == ls[1:3]

   es = [1=>2, 2=>3, 3=>4, 4=>5, 5=>1]
   g7 = subgraph(g, 1:5, es, [:p1], [:p2])
   @test nv(g7) == 5
   @test ne(g7) == 5
   @test names(vdata(g7)) == [:p1]
   @test size(vdata(g7)) == (5,1)
   @test names(edata(g7)) == [:p2]
   @test size(edata(g7)) == (5,1)
   @test encode(g7) == ls[1:5]
end
