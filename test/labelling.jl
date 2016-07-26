################################################# FILE DESCRIPTION #########################################################

# This file contains tests for LabelModule

############################################################################################################################

function test_label_module(g, ls)
   es = collect(edges(g))

   # resolve vertex
   @test resolve(g, ls[1]) == 1

   # resolve vertices
   @test all(resolve(g, ls[2:7]) .== 2:7)

   # resolve edge
   @test resolve(g, ls[2], ls[9]) == EdgeID(2, 9)

   # encode vertex
   @test encode(g, 3) == ls[3]

   # encode vertices
   @test all(encode(g, 2:7) .== ls[2:7])

   # encode edge
   @test encode(g, EdgeID(1, 8)) == Pair(ls[1], ls[8])

   # encode edges
   ls = map(x->Pair(ls[x.first],ls[x.second]), es[12:51])
   @test encode(g, es[12:51]) == ls
end


@testset "Label Module" begin
   g = complete_graph(SparseGraph, 10)

   ###
   # IDENTITYLM
   ###
   test_label_module(g, collect(1:10))

   ###
   ## DICTLM
   ###
   labels = map(string, 1:10)

   # Initialize labelling
   @test setlabel!(g, labels) == nothing

   test_label_module(g, labels)

   # rmvertex
   @test rmvertex!(g, 5) == nothing
   @test resolve(g, labels[6]) == 5

   @test rmvertex!(g, [2,6,9]) == nothing
   @test resolve(g, labels[[1, 3, 4, 8, 9]]) == [1, 2, 3, 5, 6]

   # addvertex
   @test addvertex!(g, labels[9]) == nothing
   @test resolve(g, labels[9]) == 6

   # Disable labelling
   setlabel!(g) == nothing
   @test isa(g.labelmod.lmap, IdentityLM)
end
