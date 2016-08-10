################################################# FILE DESCRIPTION #########################################################

# This file contains tests for the Vertex DataFrame.

############################################################################################################################

import Graft: eltypes

@testset "Vertex DataFrame" begin
   g = completegraph(10)
   float_arr = rand(10)
   int_arr = rand(Int, 10)
   bool_arr = rand(Bool, 10)
   str_arr = map(string, 1:10)
   void_arr = fill(nothing, 10)

   V = g.vdata

   # Mutation on emtpy DataFrame
   addvertex!(V)
   @test size(V) == (0,0)
   rmvertex!(V, 11)
   @test size(V) == (0,0)
   rmvertex!(V, 1:10)
   @test size(V) == (0,0)

   ###
   # SETVPROP
   ###
   # Try to create a property only on a subset of properties
   try setvprop!(g, rand(1:10), 1, :p1); @test false catch @test true end
   try setvprop!(g, rand(1:10, rand(1:10)), 1, :p1); @test false catch @test true end
   try setvprop!(g, :, rand(rand(1:9)), :p1); @test false catch @test true end

   # Create new properties
   setvprop!(g, :, float_arr, :p1)
   setvprop!(g, :, int_arr, :p2)
   setvprop!(g, :, bool_arr, :p3)
   setvprop!(g, :, str_arr, :p4)
   setvprop!(g, :, nothing, :p5)

   # Test property names and types
   @test listvprops(g) == [:p1, :p2, :p3, :p4, :p5]
   @test eltypes(g.vdata) == [Float64, Int, Bool, String, Void]

   # Test property values
   @test getvprop(g, :, :p1) == float_arr
   @test getvprop(g, :, :p2) == int_arr
   @test getvprop(g, :, :p3) == bool_arr
   @test getvprop(g, :, :p4) == str_arr
   @test getvprop(g, :, :p5) == void_arr

   # Mutation on DataFrame
   @test addvertex!(g) == 11
   for vprop in listvprops(g)
      isequal(getvprop(g, 11, vprop), NA)
   end

   rmvertex!(g, 11)
   @test size(g.vdata) == (10,5)

   # Modify single vertex
   v = rand(1:10)

   setvprop!(g, v, 0.5, :p1)
   @test getvprop(g, v, :p1) == 0.5

   setvprop!(g, v, "p4", :p4)
   @test getvprop(g, v, :p4) == "p4"

   # Modify a range of vertices
   setvprop!(g, 1:5, 0, :p1)
   @test getvprop(g, 1:5, :p1) == zeros(5)

   setvprop!(g, 2:7, 2:7, :p2)
   @test getvprop(g, 2:7, :p2) == collect(2:7)
end
