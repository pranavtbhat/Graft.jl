################################################# FILE DESCRIPTION #########################################################

# This file contains tests for SubGraph operations.
 
############################################################################################################################

for AM in subtypes(AdjacencyModule)
   for PM in subtypes(PropertyModule)
      @testset "Subgraph test for Graph{$AM,$PM}" begin
         g = Graph{AM,PM}(10,90)
         setvprop!(g, :, collect(1:10), "id")
         eid = 1
         seteprop!(g, :, (u,v)-> eid += 1, "weight")
         setlabel!(g, "id")

         h = subgraph(g, 3:8)
         @test getvprop(h, :, "id") == collect(3:8)
         @test resolve(h, 3) == 1
         @test resolve(h, 8) == 6
      end
   end
end
