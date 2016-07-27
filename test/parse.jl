################################################# FILE DESCRIPTION #########################################################

# This file contains tests for parse

############################################################################################################################

for AM in subtypes(AdjacencyModule)
   for PM in subtypes(PropertyModule)
      for typ in [Any,TestType]
         gtype = Graph{AM,PM{typ,typ}}
         @testset "Parsing tests for $gtype" begin
            g = completegraph(gtype, 10)

            # Vertex Properties
            setvprop!(g, :, rand(Int, 10), "f1")
            setvprop!(g, :, rand(10), "f2")
            setvprop!(g, :, [randstring() for i in 1:10], "f3")
            setvprop!(g, :, rand(Char, 10), "f5")

            # Edge properties
            seteprop!(g, :, rand(Int,90), "f1")
            seteprop!(g, :, rand(90), "f2")
            seteprop!(g, :, [randstring() for i in 1:90], "f3")
            seteprop!(g, :, rand(Char, 90), "f5")

            storegraph(g, "tmp.txt")

            h = loadgraph("tmp.txt", gtype)

            @test getvprop(g, :, "f1") == getvprop(h, :, "f1")
            @test getvprop(g, :, "f2") == getvprop(h, :, "f2")
            @test getvprop(g, :, "f3") == getvprop(h, :, "f3")
            @test getvprop(g, :, "f5") == getvprop(h, :, "f5")

            @test geteprop(g, :, "f1") == geteprop(h, :, "f1")
            @test geteprop(g, :, "f2") == geteprop(h, :, "f2")
            @test geteprop(g, :, "f3") == geteprop(h, :, "f3")
            @test geteprop(g, :, "f5") == geteprop(h, :, "f5")

            rm("tmp.txt")
         end
      end
   end
end
