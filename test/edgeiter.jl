################################################# FILE DESCRIPTION #########################################################

# This file contains tests for EdgeIter.

############################################################################################################################

@testset "Edge iteration interface" begin
   for AM in subtypes(AdjacencyModule)
      introduce("$AM")
      g = completegraph(Graph{AM,LinearPM},10)
      eit = edges(g)
      es = collect(eit)

      @test [e for e in eit] == es

      @test all(eit .== es)

      tick()
   end
end
