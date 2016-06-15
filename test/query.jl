################################################# FILE DESCRIPTION #########################################################

# This file contains tests for queries.

############################################################################################################################

for AM in subtypes(AdjacencyModule)
   for PM in subtypes(PropertyModule)
      @testset "Query tests for Graph{$AM,$PM}" begin
         g = parsegraph("testgraph.txt", :TGF, SimpleGraph)

         @test setlabel!(g, "name") == nothing

         @test resolve(g, "Abel") == 1
         
         @test g["Abel"] == getvprop(g, 1)

         @test g["Abel"=>"Bharath"] == geteprop(g, 1, 2)

         @test g["Abel", :] == ["Bharath", "Camila"]

         @test g[:, "Abel"] == ["Bharath", "Camila"]

         g["Abel", "a"] = 5
         @test getvprop(g, 1, "a") == 5

         g["Abel"=>"Bharath", "b"] = 10
         @test geteprop(g, 1, 2, "b") == 10
      end
   end
end