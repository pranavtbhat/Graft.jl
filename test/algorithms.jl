################################################# FILE DESCRIPTION #########################################################

# This file contains tests for algorithms.
############################################################################################################################

if ParallelGraphs.CAN_USE_LG

   @testset "LightGraphs Edge Interface" begin
      g = SimpleGraph(10,90)
      seteprop!(g, "weight", (u,v)->rand(1:10))

      ei = ParallelGraphs.EdgePropInterface(g, "weight")
      @test ei[1,10] == geteprop(g, 1, 10, "weight")
      @test isa(ei, AbstractArray)
      @test size(ei) == (10,10)
   end
end


# Traversals
for AM in subtypes(AdjacencyModule)
   @testset "Traversals for $AM" begin
      g = parsegraph("testgraph.txt", :TGF, Graph{AM, NullModule})

      @test bfs(g, 1) == [0,1,1,3,4,4,4,4,4,4]
      @test dfs(g, 1) == ([0,1,1,3,4,4,4,4,4,4],[0,9,1,2,8,7,6,5,4,3])
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
      println(strongly_connected_components(g))
      println(condensation(g))
   end


   # Shortest Paths

   @testset "LightGraphs Shortest Paths" begin
      g = SimpleGraph(10, 90)
      seteprop!(g, "weight", (u,v)->2)

      @test a_star(g, 1, 10) == Pair[1=>10]

      dless_arr = [0, ones(Int, 9)...]
      d_arr = [0.0, (2 * ones(9))...]
      @test dijkstra_shortest_paths(g, 1).dists == dless_arr
      @test dijkstra_shortest_paths(g, 1, "weight").dists == d_arr

      @test bellman_ford_shortest_paths(g, 1, "weight").dists == d_arr

      @test sssp(g, 1) == dless_arr
      @test sssp(g, 1, "weight") == d_arr
   end
end