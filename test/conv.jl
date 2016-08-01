################################################# FILE DESCRIPTION #########################################################

# This file contains tests for graph conversions.

############################################################################################################################


@testset "Graph Condensation" begin
   for AM in subtypes(AdjacencyModule), PM in subtypes(PropertyModule)
      gtype = Graph{AM,PM}
      introduce("$gtype")

      g = completegraph(gtype, 10)
      V,E = g

      V |> @query v.f1 = rand(Int)
      V |> @query v.f2 = rand()
      V |> @query v.f3 = randstring()
      V |> @query v.f4 = rand(Bool)
      V |> @query v.f5 = rand(Char)

      E |> @query e.f1 = rand(Int)
      E |> @query e.f2 = rand()
      E |> @query e.f3 = randstring()
      E |> @query e.f4 = rand(Bool)
      E |> @query e.f5 = rand(Char)

      h = condensation(g, Dict("1"=>(1:5), "2"=>(6:10)))

      @test isa(getvprop(h, 1, "graph"), Graph)
      @test isa(getvprop(h, 2, "graph"), Graph)

      @test getvprop(h, 1, "vertices") == 1:5
      @test getvprop(h, 2, "vertices") == 6:10

      tick()
   end
end

@testset "Graph Merging" begin
   for AM in subtypes(AdjacencyModule), PM in subtypes(PropertyModule)
      gtype = Graph{AM,PM}
      introduce("$gtype")

      g1 = completegraph(gtype, 10)
      g2 = completegraph(gtype, 10)

      setvprop!(g1, :, 1, "p1")
      setvprop!(g2, :, 2, "p1")

      setlabel!(g2, collect(11:20))

      g = merge(g1, g2)

      @test nv(g) == 20
      @test ne(g) == 180

      @test getvprop(g, 1:10, "p1") == fill(1, 10)
      @test getvprop(g, 11:20, "p1") == fill(2, 10)

      @test encode(g, vertices(g)) == collect(1:20)

      tick()
   end
end
