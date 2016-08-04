############################################################################################################################

# This file contains tests for Graph

############################################################################################################################

function graph_sanity_test(Nv::Int, Ne::Int, g::Graph)
   @test nv(g) == Nv
   @test ne(g) == Ne

   df1, df2 = g

   @test g == g
   @test copy(g) == g
   @test deepcopy(g) == g
end

function graph_label_test(Nv::Int, g::Graph, ls::Vector)
   @test nv(g) == Nv

   @test haslabel(g, rand(ls))

   u = rand(1 : Nv)
   v = rand(1 : Nv)

   @test decode(g, ls[v]) == v
   @test decode(g, ls) == collect(1:Nv)
   @test decode(g, Pair(ls[u], ls[v])) == EdgeID(u, v)

   @test encode(g, u) == ls[u]
   @test encode(g, 1 : 5) == ls[1 : 5]
   @test encode(g) == ls
   @test encode(g, EdgeID(u, v)) == Pair(ls[u], ls[v])
end

@testset "Graph Test" begin
   g = Graph(completeindxs(10))

   graph_sanity_test(10, 90, g)
   graph_label_test(10, g, collect(1:10))

   ls = map(string, 1:10)
   setlabel!(g, ls)
   graph_label_test(10, g, ls)

   relabel!(g, 10, "TEN")
   @test decode(g, "TEN") == 10
   @test encode(g, 10) == "TEN"

   relabel!(g, [8,9], ["EIGHT", "NINE"])
   @test decode(g, ["EIGHT", "NINE", "TEN"]) == [8,9,10]
   @test encode(g, 8:10) == ["EIGHT", "NINE", "TEN"]
end
