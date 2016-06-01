################################################# FILE DESCRIPTION #########################################################

# This file contains tests for the graph interface. The following interfaces are testsed:
# 1. Constructor Interface 
# 2. Basic Graph Interface
# 3. Properties Interface
 
################################################# IMPORT/EXPORT ############################################################

const graph_types = [LocalSparseGraph, LGSparseGraph]

################################################# CONSTRUCTOR INTERFACE ####################################################

for gtype in graph_types
   g = emptygraph(gtype)
   @testset "Constructor Interface for $gtype" begin
      @test isa(g, gtype)
   end
end

################################################# BASIC GRAPH INTERFACE ####################################################

for gtype in graph_types
   g = parsegraph("testgraph.txt", :TGF, gtype)
   @testset "Basic Graph Interface for $gtype" begin
      @test nv(g) == 10
      @test ne(g) == 28
      @test size(g) == (10, 28)
      @test fadj(g, 1) == [2, 3]
      @test fadj(g, 4) == [3, 5, 6, 7, 8, 9, 10]
      @test badj(g, 3) == [1, 2, 4]
      @test badj(g, 10) == [4, 9]
      @test addvertex!(g) == nothing
      @test nv(g) == 11
      @test addvertex!(g, Dict("name" => "Kamath", "age" => 32)) == nothing
      @test nv(g) == 12
      @test getvprop(g, 12, "name") == "Kamath"
      @test addedge!(g, 11, 12) == nothing
      @test ne(g) == 29
      @test addedge!(g, 12, 11, Dict("relationship" => "brother")) == nothing
      @test ne(g) == 30
      @test geteprop(g, 12, 11, "relationship") == "brother"
   end
end

################################################# PROPERTIES INTERFACE ######################################################

for gtype in graph_types
   g = parsegraph("testgraph.txt", :TGF, gtype)
   @testset "Properties Interface for $gtype" begin
      @test issubset(["name", "age"], listvprops(g))
      println(listeprops(g))
      @test issubset(["relationship"], listeprops(g))
      @test getvprop(g, 1) == Dict("name" => "Abel", "age" => 32)
      @test getvprop(g, 7, 1) == "Gaurav"
      @test getvprop(g, 9, "name") == "Ignacio"
      @test issubset(Dict("relationship" => "father"), geteprop(g, 1, 2)) 
      @test geteprop(g, 4, 9, eproptoi(ParallelGraphs.pmap(g), "relationship")) == "daughter"
      @test geteprop(g, 7, 6, "relationship") == "friend"
      addvertex!(g)
      addvertex!(g)
      @test setvprop!(g, 11, Dict("name" => "Kamath", "age" => 32)) == nothing
      @test issubset(Dict("name" => "Kamath", "age" => 32), getvprop(g, 11))
      @test setvprop!(g, 12, vproptoi(ParallelGraphs.pmap(g), "name"), "Leonid") == nothing
      @test setvprop!(g, 12, "age", 37) == nothing
      @test issubset(Dict("name" => "Leonid", "age" => 37), getvprop(g, 12))
      addedge!(g, 11, 12)
      addedge!(g, 12, 11)
      @test seteprop!(g, 11, 12, Dict("relationship" => "brother")) == nothing
      @test issubset(Dict("relationship" => "brother"), geteprop(g, 11, 12))
      @test seteprop!(g, 12, 11, eproptoi(ParallelGraphs.pmap(g), "relationship"), "brother") == nothing
      @test seteprop!(g, 12, 11, "duration", 15) == nothing
      @test issubset(Dict("relationship" => "brother", "duration" => 15), geteprop(g, 12, 11))
   end
end

