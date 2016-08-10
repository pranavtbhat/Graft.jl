################################################# FILE DESCRIPTION #########################################################

# This file contains tests for LabelModule

############################################################################################################################

function label_map_sanity_test(Nv::Int, x::LabelMap, ls::Vector)
   @test nv(x) == Nv
   @test eltype(x) == eltype(ls)
   @test x == x
   @test copy(x) == x
   @test deepcopy(x) == x

   @test haslabel(x, rand(ls))

   u = rand(1 : Nv)
   v = rand(1 : Nv)

   @test decode(x, ls[v]) == v
   @test decode(x, ls) == collect(1:Nv)
   @test decode(x, Pair(ls[u], ls[v])) == EdgeID(u, v)

   @test encode(x, u) == ls[u]
   @test encode(x, 1 : 5) == ls[1 : 5]
   @test encode(x) == ls
   @test encode(x, EdgeID(u, v)) == Pair(ls[u], ls[v])
end


@testset "Label Module" begin

   ls = map(string, 1:10)

   ###
   # IDENTITYLM
   ###
   label_map_sanity_test(10, LabelMap(10), collect(1:10))

   # Add vertex without label
   @test addvertex!(LabelMap(10)) == LabelMap(11)

   # Add vertex with next label
   @test addvertex!(LabelMap(10), 11) == LabelMap(11)

   # Add vertex with discontinuous label
   label_map_sanity_test(11, addvertex!(LabelMap(10), 12), vcat(1:10, 12))

   # Remove Vertex
   @test rmvertex!(LabelMap(10), 10) == LabelMap(9)
   @test rmvertex!(LabelMap(10), [1,2,3]) == LabelMap(7)

   # Subgraph
   @test subgraph(LabelMap(10), [1,4,7]) == LabelMap(3)

   # Setlabel
   @test setlabel!(LabelMap(10), ls) == DictLM(ls)

   # Relabel
   @test isa(relabel!(LabelMap(10), 10, 15), DictLM)


   ###
   ## DICTLM
   ###


   label_map_sanity_test(10, LabelMap(ls), ls)

   # Add vertex without label
   try addvertex!(LabelMap(ls)); @test false catch @test true end

   # Add vertex with correct type
   label_map_sanity_test(11, addvertex!(LabelMap(ls), "11"), vcat(ls, "11"))

   # Add vertex with wrong type
   try addvertex!(LabelMap(ls), 11); @test false catch @test true end

   # Remove vertex
   label_map_sanity_test(9, rmvertex!(LabelMap(ls), 10), ls[1:9])
   label_map_sanity_test(8, rmvertex!(LabelMap(ls), [1, 4]), setdiff(ls, ["1", "4"]))

   # Subgraph
   label_map_sanity_test(5, subgraph(LabelMap(ls), 1:5), ls[1:5])

   # Setlabel
   label_map_sanity_test(10, setlabel!(LabelMap(ls), 1:10), collect(1:10))

   # Relabel
   lm = LabelMap(ls)
   lm = relabel!(lm, 10, "11")
   @test decode(lm, "11") == 10
   @test encode(lm , 10) == "11"
end
