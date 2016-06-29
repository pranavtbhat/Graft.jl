################################################# FILE DESCRIPTION #########################################################

# This file contains tests for SubGraph operations.
 
############################################################################################################################

for AM in subtypes(AdjacencyModule)
   for PM in PM_LIST
      @testset "Subgraph test for Graph{$AM,$PM}" begin

         g = if PM <: StronglyTypedPM
            Graph{AM,PM{TestType,TestType}}(10,90)
         else
            Graph{AM,PM}(10, 90)
         end

         setvprop!(g, :, collect(1:10), "f1")
         eid = 1
         seteprop!(g, :, (u,v)-> eid += 1, "f1")
         setlabel!(g, "f1")

         h = subgraph(g, 3:8)
         @test getvprop(h, :, "f1") == collect(3:8)
         @test resolve(h, 3) == 1
         @test resolve(h, 8) == 6
      end
   end

end
