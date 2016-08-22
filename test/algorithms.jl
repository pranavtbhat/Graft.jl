################################################# FILE DESCRIPTION #########################################################

# This file contains tests for algorithms.
############################################################################################################################

# Traversals
@testset "Algorithms" begin
   g = loadgraph("testgraph.txt")

   @test bfs(g, 1) == [0,1,1,3,4,4,4,4,4,4]
   @test bfs(g, 1, 2) == [0,1,1,3,-1,-1,-1,-1,-1,-1]
   @test bfs(g, 1, 3) == [0,1,1,3,4,4,4,4,4,4]

   @test bfs_list(g, 1) == [2,3,4,5,6,7,8,9,10]
   @test bfs_list(g, 2) == [1,3,4,5,6,7,8,9,10]
   @test bfs_list(g, 1, 1, 2) == [2,3,4]
   @test bfs_list(g, 1, 2, 3) == [4,5,6,7,8,9,10]

   g1 = bfs_tree(g, 1, 2)
   @test nv(g1) == 4
   @test ne(g1) == 3

   g2 = bfs_tree(g, 1, 4)
   @test nv(g2) == 10
   @test ne(g2) == 9

   g3 = bfs_subgraph(g, 1, 2)
   @test nv(g3) == 4
   @test ne(g3) == 8

   g4 = bfs_subgraph(g, 1, 4)
   @test nv(g4) == 10
   @test ne(g4) == 28

   ###
   # External interface
   ###
   setlabel!(g, map(string, 1:10))
   @test hoplist(g, "1", 1, 2) == ["2","3","4"]

   g5 = hoptree(g, "1", 2)
   @test nv(g5) == 4
   @test ne(g5) == 3

   g6 = hopgraph(g, "1", 2)
   @test nv(g6) == 4
   @test ne(g6) == 8

   ###
   # Mutual friends
   ###
   g = completegraph(10)
   setlabel!(g, map(string, 1:10))
   @test mutualcount(g, "1", "2") == 8
   @test mutual(g, "1", "2") == map(string, [3,4,5,6,7,8,9,10])
end
