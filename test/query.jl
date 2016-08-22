################################################# FILE DESCRIPTION #########################################################

# This file contains tests for graph conversions.

############################################################################################################################

@testset "Eachvertex" begin
   g = completegraph(10)

   # Set vertex properties
   setvprop!(g, :, 1 : 10, :p1)
   setvprop!(g, :, 1 : 10, :p2)
   setvprop!(g, :, 1 : 10, :p3)
   setvprop!(g, :, 1 : 10, :p4)

   arr = getvprop(g, :, :p1)

   # Straightforward fetch prop
   @test @query(g |> eachvertex(v.p1)) == arr

   # Add constant
   @test @query(g |> eachvertex(v.p2 + 3)) == arr .+ 3

   # Add two props
   @test @query(g |> eachvertex(v.p2 + v.p3)) == arr .+ arr

   # Parenthesis
   @test @query(g |> eachvertex((v.p1 + v.p2)/(v.p3 * v.p4))) == (arr .+ arr) ./ (arr .* arr)

   # Special tokens
   setlabel!(g, map(string, 1 : 10))
   @test @query(g |> eachvertex(v.id)) == collect(vertices(g))
   @test @query(g |> eachvertex(v.adj)) == [fadj(g, v) for v in vertices(g)]
   @test @query(g |> eachvertex(v.nbors)) == [g[v] for v in encode(g)]
   @test @query(g |> eachvertex(v.indegree)) == indegree(g)
   @test @query(g |> eachvertex(v.outdegree)) == outdegree(g)
   @test @query(g |> eachvertex(v.label)) == encode(g)
end

@testset "EachEdge" begin
   g = completegraph(10)

   # Set vertex properties
   setvprop!(g, :, 1 : 10, :p1)
   setvprop!(g, :, 1 : 10, :p2)
   setvprop!(g, :, 1 : 10, :p3)
   setvprop!(g, :, 1 : 10, :p4)

   # Set edge properties
   seteprop!(g, :, 1 : 90, :p1)
   seteprop!(g, :, 1 : 90, :p2)
   seteprop!(g, :, 1 : 90, :p3)
   seteprop!(g, :, 1 : 90, :p4)

   arr = geteprop(g, :, :p1)

   # Straightforward fetch prop
   @test @query(g |> eachedge(e.p1)) == arr

   # Add constant
   @test @query(g |> eachedge(e.p2 + 3)) == arr .+ 3

   # Add two props
   @test @query(g |> eachedge(e.p2 + e.p3)) == arr .+ arr

   # Parenthesis
   @test @query(g |> eachedge((e.p1 + e.p2)/(e.p3 * e.p4))) == (arr .+ arr) ./ (arr .* arr)

   # Source == target
   @test @query(g |> eachedge(s.p1 == t.p1)) == falses(90)

   # Source + target
   @test @query(g |> eachedge(s.p1 + t.p2 > 0 )) == trues(90)

   # Special tokens
   setlabel!(g, map(string, 1 : 10))
   eit = edges(g)
   @test @query(g |> eachedge(s.id)) == eit.us
   @test @query(g |> eachedge(t.id)) == eit.vs

   @test @query(g |> eachedge(s.label)) == encode(g, eit.us)
   @test @query(g |> eachedge(t.label)) == encode(g, eit.vs)

   @test @query(g |> eachedge(e.source)) == @query(g |> eachedge(s.label)) == encode(g, eit.us)
   @test @query(g |> eachedge(e.target)) == @query(g |> eachedge(t.label)) == encode(g, eit.vs)

   @test @query(g |> eachedge(s.adj)) == [fadj(g, v) for v in eit.us]
   @test @query(g |> eachedge(t.adj)) == [fadj(g, v) for v in eit.vs]

   @test @query(g |> eachedge(s.nbors)) == [g[v] for v in encode(g, eit.us)]
   @test @query(g |> eachedge(t.nbors)) == [g[v] for v in encode(g, eit.vs)]

   @test @query(g |> eachedge(s.indegree)) == indegree(g, eit.us)
   @test @query(g |> eachedge(s.outdegree)) == outdegree(g, eit.us)

   @test @query(g |> eachedge(t.indegree)) == indegree(g, eit.vs)
   @test @query(g |> eachedge(t.outdegree)) == outdegree(g, eit.vs)
end

@testset "Filter" begin
   g = completegraph(10)
   setlabel!(g, collect(1:10))
   # Set vertex properties
   setvprop!(g, :, 1 : 10, :p1)
   setvprop!(g, :, 1 : 10, :p2)
   setvprop!(g, :, 1 : 10, :p3)
   setvprop!(g, :, 1 : 10, :p4)

   # Set edge properties
   seteprop!(g, :, 1 : 90, :p1)
   seteprop!(g, :, 1 : 90, :p2)
   seteprop!(g, :, 1 : 90, :p3)
   seteprop!(g, :, 1 : 90, :p4)

   # Filter on vertex property
   g1 = @query(g |> filter(v.p1 <= 5))
   @test @query(g1 |> eachvertex(v.p1)) == collect(1:5)
   @test nv(g1) == 5
   @test ne(g1) == 20
   @test encode(g1) == [1,2,3,4,5]

   # Filter on edge property
   g2 = @query(g |> filter(e.p1 <= 45))
   @test @query(g2 |> eachedge(e.p1)) == collect(1:45)
   @test nv(g2) == 10
   @test ne(g2) == 45

   # Multiple vertex properties
   g3 = @query(g |> filter(v.p1 <=10, v.p2 >= 7))
   @test @query(g3 |> eachvertex(v.p1)) == collect(7:10)
   @test nv(g3) == 4
   @test ne(g3) == 12
   @test encode(g3) == [7,8,9,10]

   # Multiple edge properties
   g4 = @query(g |> filter(e.p1 <= 70, e.p2 >= 60))
   @test @query(g4 |> eachedge(e.p1)) == collect(60:70)
   @test nv(g4) == 10
   @test ne(g4) == 11

   # Mixed properties
   g5 = @query(g |> filter(v.p1 <= 5, e.p1 <= 20))
   @test nv(g5) == 5
   @test ne(g5) == 10

   # Source and target properites
   g6 = @query(g |> filter(s.p1 < t.p1))
   @test nv(g6) == 10
   @test ne(g6) == 45
end

@testset "Select" begin
   g = completegraph(10)
   # Set vertex properties
   setvprop!(g, :, 1 : 10, :p1)
   setvprop!(g, :, 1 : 10, :p2)
   setvprop!(g, :, 1 : 10, :p3)
   setvprop!(g, :, 1 : 10, :p4)

   # Set edge properties
   seteprop!(g, :, 1 : 90, :p1)
   seteprop!(g, :, 1 : 90, :p2)
   seteprop!(g, :, 1 : 90, :p3)
   seteprop!(g, :, 1 : 90, :p4)

   # Vertex props
   g1 = @query(g |> select(v.p1, v.p3))
   @test listvprops(g1) == [:p1, :p3]
   @test size(vdata(g1)) == (10,2)

   # Edge props
   g2 = @query(g |> select(e.p2, e.p4))
   @test listeprops(g2) == [:p2, :p4]
   @test size(edata(g2)) == (90,2)

   # Mixed props
   g3 = @query(g |> select(v.p1, v.p4, e.p2, e.p3))
   @test listvprops(g3) == [:p1, :p4]
   @test size(vdata(g3)) == (10,2)
   @test listeprops(g3) == [:p2, :p3]
   @test size(edata(g3)) == (90,2)
end
