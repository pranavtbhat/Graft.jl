################################################# FILE DESCRIPTION #########################################################

# This file contains tests for parse

############################################################################################################################

for AM in subtypes(AdjacencyModule)
   for PM in subtypes(PropertyModule)
      for typ in [Any,TestType]
         gtype = Graph{AM,PM{typ,typ}}
         @testset "Parsing tests for $gtype" begin
            g = gtype(10, 90)

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

            @test getvprop(g, :) == getvprop(h, :)

            @test geteprop(g, :) == geteprop(h, :)

            rm("tmp.txt")
         end
      end
   end
end
