################################################# FILE DESCRIPTION #########################################################

# This file contains tests for SubGraph operations.

############################################################################################################################

for AM in subtypes(AdjacencyModule)
   for PM in subtypes(PropertyModule)
      for typ in [Any, TestType]
         @testset "Subgraph test for Graph{$AM,$(PM{typ,typ})}" begin

            g = Graph{AM,PM{typ,typ}}(10,90)

            setvprop!(g, :, collect(1:10), "f1")
            seteprop!(g, :, 1:90, "f1")
            setlabel!(g, "f1")

            h = subgraph(g, 3:8)
            @test getvprop(h, :, "f1") == collect(3:8)
            @test resolve(h, 3) == 1
            @test resolve(h, 8) == 6
         end
      end
   end
end
