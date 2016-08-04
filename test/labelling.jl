################################################# FILE DESCRIPTION #########################################################

# This file contains tests for LabelModule

############################################################################################################################

function test_label_module(g, ls)
   @test nv(g.labelmod) == nv(g)

   es = collect(edges(g))

   # decode vertex
   @test decode(g, ls[1]) == 1

   # decode vertices
   @test all(decode(g, ls[2:7]) .== 2:7)

   # decode edge
   @test decode(g, ls[2], ls[9]) == EdgeID(2, 9)

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
   g = completegraph(SparseGraph, 10)

   ###
   # IDENTITYLM
   ###
   test_label_module(g, collect(1:10))

   ###
   ## DICTLM
   ###
   ls = map(string, 1:10)

   # Initialize labelling
   @test setlabel!(g, ls) == nothing

   test_label_module(g, ls)

   # rmvertex
   @test rmvertex!(g, 5) == nothing
   @test decode(g, ls[6]) == 5

   @test rmvertex!(g, [2,6,9]) == nothing
   @test decode(g, ls[[1, 3, 4, 8, 9]]) == [1, 2, 3, 5, 6]

   # addvertex
   @test addvertex!(g, ls[9]) == 6

   # Disable labelling
   setlabel!(g) == nothing
   @test isa(g.labelmod.lmap, IdentityLM)

   ###
   # MIXED TYPES
   ###
   g = completegraph(SparseGraph, 10)

   addvertex!(g, 11.0)
   setlabel!(g, 3, '3')
   setlabel!(g, 5:9, map(string, 5:9))
   ls = encode(g, vertices(g))

   test_label_module(g, ls)
end
