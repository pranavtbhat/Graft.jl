################################################# FILE DESCRIPTION #########################################################

# This file contains tests for algorithms.
############################################################################################################################

if ParallelGraphs.CAN_USE_LG

   @testset "LightGraphs Edge Interface" begin
      g = SimpleGraph(10,90)
      seteprop!(g, :, (u,v)->rand(1:10), "weight")

      ei = ParallelGraphs.EdgePropInterface(g, "weight")
      @test ei[1,10] == geteprop(g, 1, 10, "weight")
      @test isa(ei, AbstractArray)
      @test size(ei) == (10,10)
   end
end


# Traversals
for AM in subtypes(AdjacencyModule)
   @testset "Traversals for $AM" begin
      g = loadgraph("testgraph.txt", Graph{AM, NullModule})

      @test bfs(g, 1) == [0,1,1,3,4,4,4,4,4,4]
      @test dfs(g, 1) == ([0,1,1,3,4,4,4,4,4,4],[0,9,1,2,8,7,6,5,4,3])

      @test ne(bfs_subgraph(g, 1)) == 9
      @test ne(dfs_subgraph(g, 1)) == 9
   end
end


if ParallelGraphs.CAN_USE_LG
   ###
   # These algorithms are well tested in the LightGraphs package. Just some basic tests for the wrappers.
   ###


   # Connectivity

   @testset "LightGraphs Connectivity" begin
      g = SimpleGraph(10,90)

      @test is_connected(g) == true
      @test is_strongly_connected(g) == true
      @test is_weakly_connected(g) == true
      @test length(strongly_connected_components(g)) == 1
      @test nv(condensation(g)) == 1
   end


   # Shortest Paths

   @testset "LightGraphs Shortest Paths" begin
      g = SimpleGraph(10, 90)
      seteprop!(g, :, (u,v)->2, "weight")

      @test a_star(g, 1, 10) == Pair[1=>10]

      dless_arr = [0, ones(Int, 9)...]
      d_arr = [0.0, (2 * ones(9))...]
      @test dijkstra_shortest_paths(g, 1).dists == dless_arr
      @test dijkstra_shortest_paths(g, 1, "weight").dists == d_arr

      @test bellman_ford_shortest_paths(g, 1, "weight").dists == d_arr

      @test sssp(g, 1) == dless_arr
      @test sssp(g, 1, "weight") == d_arr
   end

   # Centrality
   @testset "LightGraphs Centrality" begin
      g = SimpleGraph(10, 90)
      h = g.adjmod.data
      @test betweenness_centrality(g) == LightGraphs.betweenness_centrality(h)
      @test degree_centrality(g) == LightGraphs.degree_centrality(h)
      @test indegree_centrality(g) == LightGraphs.indegree_centrality(h)
      @test outdegree_centrality(g) == LightGraphs.outdegree_centrality(h)
      @test closeness_centrality(g) == LightGraphs.closeness_centrality(h)
      @test katz_centrality(g) == LightGraphs.katz_centrality(h)
      @test pagerank(g) == LightGraphs.pagerank(h)
   end
end
