################################################# FILE DESCRIPTION #########################################################

# This file contains tests for graph conversions.

############################################################################################################################

@testset "Graph Merging" begin
   g = completegraph(10)
   eit = edges(g)

   g1 = subgraph(g, eit[1:45])
   g2 = subgraph(g, eit[46:90])

   h = merge(g1, g2)
   @test h == g
end
