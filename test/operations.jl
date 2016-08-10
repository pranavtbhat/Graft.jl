################################################# FILE DESCRIPTION #########################################################

# This file contains tests for graph conversions.

############################################################################################################################

@testset "Export" begin
   g = completegraph(10)

   setvprop!(g, :, 1:10, :p1)
   seteprop!(g, :, 1:90, :p1)

   @test export_adjacency(g) == indxs(g)
   @test export_vertex_property(g, :p1) == collect(1:10)

   sv = export_edge_property(g, :p1)
   @test nnz(sv) == 90
end

@testset "Graph Merging" begin
   g = completegraph(10)
   eit = edges(g)

   g1 = subgraph(g, eit[1:45])
   g2 = subgraph(g, eit[46:90])

   h = merge(g1, g2)
   @test h == g
end
