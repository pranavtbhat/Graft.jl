################################################# FILE DESCRIPTION #########################################################

# This file contains tests for the Vertex DataFrame.

############################################################################################################################

@testset "Edge DataFrame" begin
   g = completegraph(10)

   eit = edges(g)

   float_arr = rand(90)
   int_arr = rand(Int, 90)
   bool_arr = rand(Bool, 90)
   str_arr = map(string, 1:90)
   void_arr = fill(nothing, 90)

   E = g.edata

   # Mutation on emtpy DataFrame
   addedge!(E)
   @test size(E) == (0,0)
   rmedge!(E, 11)
   @test size(E) == (0,0)
   rmedge!(E, 1:90)
   @test size(E) == (0,0)

   ###
   # SETVPROP
   ###
   # Try to create a property only on a subset of properties
   try seteprop!(g, eit[rand(1:90)], 1, :p1); @test false catch @test true end
   try seteprop!(g, eit[rand(1:90, rand(1:90))], 1, :p1); @test false catch @test true end
   try seteprop!(g, :, rand(rand(1:89)), :p1); @test false catch @test true end

   # Create new properties
   seteprop!(g, :, float_arr, :p1)
   seteprop!(g, :, int_arr, :p2)
   seteprop!(g, :, bool_arr, :p3)
   seteprop!(g, :, str_arr, :p4)
   seteprop!(g, :, nothing, :p5)

   # Test property names and types
   @test listeprops(g) == [:p1, :p2, :p3, :p4, :p5]
   @test eltypes(g.edata) == [Float64, Int, Bool, String, Void]

   # Test property values
   @test geteprop(g, :, :p1) == float_arr
   @test geteprop(g, :, :p2) == int_arr
   @test geteprop(g, :, :p3) == bool_arr
   @test geteprop(g, :, :p4) == str_arr
   @test geteprop(g, :, :p5) == void_arr

   # Mutation on DataFrame
   @test addedge!(g, 1=>1) == true
   @test g.indxs[1=>1] == 91
   for eprop in listeprops(g)
      isequal(geteprop(g, 1=>1, eprop), NA)
   end

   rmedge!(g, 1=>1)
   @test size(g.edata) == (90,5)

   # Modify single edge
   e = rand(eit)

   seteprop!(g, e, 0.5, :p1)
   @test geteprop(g, e, :p1) == 0.5

   seteprop!(g, e, "p4", :p4)
   @test geteprop(g, e, :p4) == "p4"

   # Modify a range of edges
   es = rand(eit, 20)
   seteprop!(g, es, 0, :p1)
   @test geteprop(g, es, :p1) == zeros(20)

   es = unique(rand(eit, 50))
   vals = 1 : length(es)
   seteprop!(g, es, vals, :p2)
   @test geteprop(g, es, :p2) == collect(vals)
end
