################################################# FILE DESCRIPTION #########################################################

# This file contains tests for SubGraph operations.

############################################################################################################################

@testset "Subgraph tests" begin
   for AM in subtypes(AdjacencyModule), PM in subtypes(PropertyModule), typ in [Any,TestType]
      gtype = Graph{AM,PM{typ,typ}}
      introduce("$gtype")
      g = completegraph(gtype, 10)
      vlist = 3:8
      elist = 11:20
      es = edges(g)[elist]
      es1 = edges(g)[1:45]

      vf1 = collect(1:10)
      vf2 = 1.0 * collect(1:10)
      vf3 = ["$i" for i in 1:10]

      ef1 = collect(1:90)
      ef2 = 1.0 * collect(1:90)
      ef3 = ["$i" for i in 1:90]

      # Vertex Properties
      setvprop!(g, :, vf1, "f1")
      setvprop!(g, :, vf2, "f2")
      setvprop!(g, :, vf3, "f3")

      # Edge Properties
      seteprop!(g, :, ef1, "f1")
      seteprop!(g, :, ef2, "f2")
      seteprop!(g, :, ef3, "f3")

      # Labels
      setlabel!(g, "f1")

      # Vertex Subgraphing
      h = subgraph(g, vlist)
      @test size(h) == (6, 30)
      @test getvprop(h, :, "f1") == vf1[vlist]
      @test decode(h, 3) == 1
      @test decode(h, 8) == 6

      # Vertex and Property Subgraphing
      h = subgraph(g, vlist, ["f1", "f3"])
      @test size(h) == (6, 30)
      @test getvprop(h, :, "f1") == vf1[vlist]
      @test getvprop(h, :, "f3") == vf3[vlist]
      try getvprop(h, :, "f2"); @test false catch @test true end


      # Edge Subgraphing
      h = subgraph(g, es)
      @test size(h) == (10, 10)
      @test getvprop(h, :, "f2") == vf2
      @test geteprop(h, :, "f1") == ef1[elist]
      @test geteprop(h, :, "f3") == ef3[elist]

      # Edge and Property Subgraphing
      h = subgraph(g, es, ["f1", "f2"])
      @test size(h) == (10, 10)
      @test geteprop(h, :, "f1") == ef1[elist]
      @test geteprop(h, :, "f2") == ef2[elist]
      try geteprop(h, :, "f3"); @test false catch @test true end

      # Vertex and Edge Subgraphing
      h = subgraph(g, vlist, es1)
      @test size(h) == (6, 15)

      # All Subgraphing
      h = subgraph(g, vlist, es1, ["f2", "f3"], ["f2", "f3"])
      @test size(h) == (6, 15)
      try getvprop(h, :, "f1"); @test false catch @test true end
      try geteprop(h, :, "f1"); @test false catch @test true end

      tick()
   end
end
