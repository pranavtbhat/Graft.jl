################################################# FILE DESCRIPTION #########################################################

# This file contains tests for PropertyModules
 
############################################################################################################################


for pmtype in subtypes(PropertyModule)
   @testset "Properties Interface for $pmtype" begin
      g = parsegraph("testgraph.txt", :TGF, Graph{NullModule, pmtype})
      @test listvprops(g) == ["name", "age"]
      @test listeprops(g) == ["relationship"]
      @test getvprop(g, 1) == Dict("name" => "Abel", "age" => 32)
      @test getvprop(g, 9, "name") == "Ignacio"
      @test geteprop(g, 1, 2) == Dict("relationship" => "father")
      @test geteprop(g, 7, 6, "relationship") == "friend"

      @test setvprop!(g, 11, Dict("name" => "Kamath", "age" => 32)) == nothing
      @test getvprop(g, 11) == Dict("name" => "Kamath", "age" => 32)
      @test setvprop!(g, 12, "age", 37) == nothing
      @test getvprop(g, 12, "age") == 37
      @test seteprop!(g, 11, 12, Dict("relationship" => "brother")) == nothing
      @test seteprop!(g, 11, 12, "duration", 15) == nothing
      @test geteprop(g, 11, 12) == Dict("relationship" => "brother", "duration" => 15)

      # @test rmvertex!(g, 1) == nothing
      # @test isempty(getvprop(g, 1))
      # @test isempty(geteprop(g, 1, 2))

      # @test rmedge!(g, 11, 12) == nothing
      # @test isempty(geteprop(g, 11, 12))
   end
end