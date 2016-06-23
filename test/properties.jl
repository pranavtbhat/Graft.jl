################################################# FILE DESCRIPTION #########################################################

# This file contains tests for PropertyModules
 
############################################################################################################################


for pmtype in subtypes(PropertyModule)
   @testset "Properties Interface for $pmtype" begin
      g = parsegraph("testgraph.txt", :TGF, Graph{SparseMatrixAM, pmtype})
      @test listvprops(g) == ["name", "age"]
      @test listeprops(g) == ["relationship"]
      @test getvprop(g, 1) == Dict("name" => "Abel", "age" => 32)
      @test getvprop(g, 9, "name") == "Ignacio"
      @test geteprop(g, 1, 2) == Dict("relationship" => "father")
      @test geteprop(g, 7, 6, "relationship") == "friend"

      addvertex!(g)
      addvertex!(g)
      addedge!(g, 11, 12)

      @test setvprop!(g, 11, Dict("name" => "Kamath", "age" => 32)) == nothing
      @test getvprop(g, 11) == Dict("name" => "Kamath", "age" => 32)
      @test setvprop!(g, 12, 37, "age") == nothing
      @test getvprop(g, 12, "age") == 37
      @test seteprop!(g, 11, 12, Dict("relationship" => "brother")) == nothing
      @test seteprop!(g, 11, 12, 15, "duration") == nothing
      @test geteprop(g, 11, 12) == Dict("relationship" => "brother", "duration" => 15)

      # @test rmvertex!(g, 1) == nothing
      # @test isempty(getvprop(g, 1))
      # @test isempty(geteprop(g, 1, 2))

      # @test rmedge!(g, 11, 12) == nothing
      # @test isempty(geteprop(g, 11, 12))


      @test setvprop!(g, :, collect(1 : 12), "index") == nothing
      @test sum([getvprop(g, v, "index") for v in 1 : nv(g)]) == 78

      @test setvprop!(g, :, v->v % 9, "favdigit") == nothing
      @test isa(Int[getvprop(g, v, "favdigit") for v in 1 : nv(g)], Vector{Int})

      @test seteprop!(g, :, (u,v)->u+v, "weight") == nothing
      @test isa(Int[geteprop(g, u, v, "weight") for (u,v) in edges(g)], Vector{Int})
   end
end