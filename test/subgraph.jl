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
   setvprop!(g, :, 1:10, :p3)
   setvprop!(g, :, 1:10, :p4)

   # Set edge properties
   seteprop!(g, :, 1:90, :p1)
   seteprop!(g, :, 1:90, :p2)
   seteprop!(g, :, 1:90, :p3)
   seteprop!(g, :, 1:90, :p4)

   # Copy
   g1 = subgraph(g)
   @test isequal(g1, g)

   # VS
   g2 = subgraph(g, 1:5)
   @test nv(g2) == 5
   @test ne(g2) == 20
   @test size(vdata(g2)) == (5, 4)
   @test size(edata(g2)) == (20, 4)
   @test encode(g2) == ls[1:5]

   # VPROPS
   g3 = subgraph(g, :, [:p1, :p3])
   @test nv(g3) == 10
   @test names(vdata(g3)) == [:p1, :p3]
   @test size(vdata(g3)) == (10, 2)

   # VS & VPROPS
   g4 = subgraph(g, 1:7, [:p2, :p4])
   @test nv(g4) == 7
   @test ne(g4) == 42
   @test names(vdata(g4)) == [:p2, :p4]
   @test size(vdata(g4)) == (7,2)
   @test size(edata(g4)) == (42,4)
   @test encode(g4) == ls[1:7]

   # ES
   es = eit[1:45]
   g5 = subgraph(g, es)
   @test nv(g5) == 10
   @test ne(g5) == 45
   @test size(edata(g5)) == (45,4)

   # EPROPS
   g6 = subgraph(g, :, :, [:p1,:p4])
   @test ne(g6) == 90
   @test names(edata(g6)) == [:p1,:p4]
   @test size(edata(g6)) == (90,2)

   # ES & EPROPS
   es = eit[35:70]
   g7 = subgraph(g, es, [:p1])
   @test nv(g7) == 10
   @test ne(g7) == 36
   @test names(edata(g7)) == [:p1]
   @test size(edata(g7)) == (36,1)

   # VS & ES
   es = [1=>2, 2=>3, 3=>1]
   g8 = subgraph(g, 1:3, es)
   @test nv(g8) == 3
   @test ne(g8) == 3
   @test encode(g8) == ls[1:3]

   es = [1=>2, 2=>3, 3=>4, 4=>5, 5=>1]
   g9 = subgraph(g, 1:5, es, [:p1], [:p2])
   @test nv(g9) == 5
   @test ne(g9) == 5
   @test names(vdata(g9)) == [:p1]
   @test size(vdata(g9)) == (5,1)
   @test names(edata(g9)) == [:p2]
   @test size(edata(g9)) == (5,1)
   @test encode(g9) == ls[1:5]
end
