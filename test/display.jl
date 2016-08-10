################################################# FILE DESCRIPTION #########################################################

# This file contains tests for utils

############################################################################################################################

@testset "Display" begin
   g = completegraph(10)
   setlabel!(g, map(string, 1:10))

   # Set vertex properties
   setvprop!(g, :, 1 : 10, :p1)
   setvprop!(g, :, 1 : 10, :p2)
   setvprop!(g, :, 1 : 10, :p3)
   setvprop!(g, :, 1 : 10, :p4)

   # Set edge properties
   seteprop!(g, :, 1 : 90, :p1)
   seteprop!(g, :, 1 : 90, :p2)
   seteprop!(g, :, 1 : 90, :p3)
   seteprop!(g, :, 1 : 90, :p4)

   V, E = g
   @test isa(V, VertexDescriptor)
   @test isa(E, EdgeDescriptor)

   ss = IOBuffer()

   # Show
   println(ss, V)
   println(ss, E)

   # Getindex V
   println(ss, V["1"])
   try println(ss, V["11"]); @test false catch @test true end

   # Getindex E
   println(ss, E["1", "2"])
   try println(ss, V["1", "1"]); @test false catch @test true end
end
