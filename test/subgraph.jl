################################################# FILE DESCRIPTION #########################################################

# This file contains tests for SubGraph operations.
 
############################################################################################################################

for AM in subtypes(AdjacencyModule)
   for PM in subtypes(PropertyModule)
      @testset "Subgraph test for Graph{$AM,$PM}" begin
         g = Graph{AM,PM}(20,60)
         setvprop!(g, "id", collect(1:20))

         eid = 1
         seteprop!(g, "weight", (u,v)-> eid += 1)

         h = subgraph(g, 5:15)

         @test [getvprop(h, v, "id") for v in vertices(h)] == collect(5:15)

         elist = []
         for e in edges(h)
            push!(elist, e)
         end
         @test isa(Int[geteprop(h, e..., "weight") for e in elist], Vector{Int})
      end
   end
end
