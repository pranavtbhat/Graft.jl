################################################# FILE DESCRIPTION #########################################################

# This file contains tests for PropertyModules

############################################################################################################################


for PM in subtypes(PropertyModule)
   for typ in [Any,TestType]
      @testset "Properties Interface for $(PM{typ,typ})" begin

         g = Graph{SparseMatrixAM,PM{typ,typ}}(10,90)

         cmp = Array{Any}(10)

         setvprop!(g, 1, Dict("f1"=>1))

         if typ == Any
            @test getvprop(g, 1) == Dict("f1"=>1)
         else
            @test getvprop(g, 1) == Dict("f1"=>1, "f2"=>0.0, "f3"=>"", "f4"=>nothing, "f5"=>'\0')
         end

         @test getvprop(g, 1, "f1") == 1

         setvprop!(g, 1:10, [Dict("f1"=>1) for i in 1:10])
         @test getvprop(g, 1:10, "f1") == getvprop(g, :, "f1") == fill!(cmp, 1)

         setvprop!(g, :, [Dict("f2"=>2.0) for i in 1:10])
         @test getvprop(g, :, "f2") == fill!(cmp, 2.0)

         setvprop!(g, 2, "3", "f3")
         @test getvprop(g, 2, "f3") == "3"

         setvprop!(g, 1:10, fill("3", 10), "f3")
         @test getvprop(g, 1:10, "f3") == fill!(cmp, "3")

         setvprop!(g, 1:10, v->Colon(), "f4")
         @test getvprop(g, 1:10, "f4")  == fill!(cmp, Colon())

         setvprop!(g, :, fill('0', 10), "f5")
         @test getvprop(g, :, "f5") == fill!(cmp, '0')

         setvprop!(g, :, '5', "f5")
         @test all(getvprop(g, :) .== Dict("f1"=>1, "f2"=>2.0, "f3"=>"3", "f4"=>Colon(), "f5"=>'5'))

         cmp = Array{Any}(10)

         elist = collect(edges(g))[11:20]
         dlist = [Dict("f1"=>1) for i in 1:10]
         str_dlist = fill(Dict("f1"=>1, "f2"=>0.0, "f3"=>"", "f4"=>nothing, "f5"=>'\0'), 10)

         seteprop!(g, 1, 2, Dict("f1"=>1))

         if typ == Any
            @test geteprop(g, 1, 2) == Dict("f1"=>1)
         else
            @test geteprop(g, 1, 2) == Dict("f1"=>1, "f2"=>0.0, "f3"=>"", "f4"=>nothing, "f5"=>'\0')
         end

         seteprop!(g, 2=>3, Dict("f1"=>1))

         if typ == Any
            @test geteprop(g, 2=>3) == Dict("f1"=>1)
         else
            @test geteprop(g, 2=>3) == Dict("f1"=>1, "f2"=>0.0, "f3"=>"", "f4"=>nothing, "f5"=>'\0')
         end

         seteprop!(g, elist, dlist)

         if typ == Any
            @test geteprop(g, elist) == dlist
         else
            @test geteprop(g, elist) == str_dlist
         end

         seteprop!(g, 3, 4, 2.0, "f2")
         @test geteprop(g, 3, 4, "f2") == 2.0

         seteprop!(g, 5=>6, 2.0, "f2")
         @test geteprop(g, 5=>6, "f2") == 2.0

         seteprop!(g, elist, fill(2.0, 10), "f2")
         @test all(geteprop(g, elist, "f2") .== 2.0)

         seteprop!(g, elist, "3", "f3")
         @test all(geteprop(g, elist, "f3") .== "3")

         seteprop!(g, :, Colon(), "f4")
         @test all(geteprop(g, :, "f4") .== Colon())

         seteprop!(g, :, '5', "f5")
         @test all(geteprop(g, :, "f5") .== '5')

         # Adjacency Tests
         @test addvertex!(g) == nothing
         @test addvertex!(g, 2) == nothing
         @test addedge!(g, 11, 12) == nothing
         @test addedge!(g, EdgeID[12=>13, 11=>13]) == nothing

         # Remove vertices and edges
         rmvertex!(g, 13) == nothing
         @test nv(g) == 12

         rmedge!(g, 11, 12) == nothing
         rmvertex!(g, [11,12]) == nothing
         @test nv(g) == 10
         @test ne(g) == 90
      end
   end
end
