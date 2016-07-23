################################################# FILE DESCRIPTION #########################################################

# This file contains tests for PropertyModules

############################################################################################################################


for PM in subtypes(PropertyModule)
   for typ in [Any,TestType]
      @testset "Properties Interface for $(PM{typ,typ})" begin

         x = PM{typ,typ}(10,90)

         cmp = Array{Any}(10)

         setvprop!(x, 1, Dict("f1"=>1))

         if typ == Any
            @test getvprop(x, 1) == Dict("f1"=>1)
         else
            @test getvprop(x, 1) == Dict("f1"=>1, "f2"=>0.0, "f3"=>"", "f4"=>nothinx, "f5"=>'\0')
         end

         @test getvprop(x, 1, "f1") == 1

         setvprop!(x, 1:10, [Dict("f1"=>1) for i in 1:10])
         @test getvprop(x, 1:10, "f1") == getvprop(x, :, "f1") == fill!(cmp, 1)

         setvprop!(x, :, [Dict("f2"=>2.0) for i in 1:10])
         @test getvprop(x, :, "f2") == fill!(cmp, 2.0)

         setvprop!(x, 2, "3", "f3")
         @test getvprop(x, 2, "f3") == "3"

         setvprop!(x, 1:10, fill("3", 10), "f3")
         @test getvprop(x, 1:10, "f3") == fill!(cmp, "3")

         setvprop!(x, 1:10, v->Colon(), "f4")
         @test getvprop(x, 1:10, "f4")  == fill!(cmp, Colon())

         setvprop!(x, :, fill('0', 10), "f5")
         @test getvprop(x, :, "f5") == fill!(cmp, '0')

         setvprop!(x, :, '5', "f5")
         @test all(getvprop(x, :) .== Dict("f1"=>1, "f2"=>2.0, "f3"=>"3", "f4"=>Colon(), "f5"=>'5'))

         cmp = Array{Any}(10)

         elist = collect(edges(x))[11:20]
         dlist = [Dict("f1"=>1) for i in 1:10]
         str_dlist = fill(Dict("f1"=>1, "f2"=>0.0, "f3"=>"", "f4"=>nothinx, "f5"=>'\0'), 10)

         seteprop!(x, 1, 2, Dict("f1"=>1))

         if typ == Any
            @test geteprop(x, 1, 2) == Dict("f1"=>1)
         else
            @test geteprop(x, 1, 2) == Dict("f1"=>1, "f2"=>0.0, "f3"=>"", "f4"=>nothinx, "f5"=>'\0')
         end

         seteprop!(x, 2=>3, Dict("f1"=>1))

         if typ == Any
            @test geteprop(x, 2=>3) == Dict("f1"=>1)
         else
            @test geteprop(x, 2=>3) == Dict("f1"=>1, "f2"=>0.0, "f3"=>"", "f4"=>nothinx, "f5"=>'\0')
         end

         seteprop!(x, elist, dlist)

         if typ == Any
            @test geteprop(x, elist) == dlist
         else
            @test geteprop(x, elist) == str_dlist
         end

         seteprop!(x, 3, 4, 2.0, "f2")
         @test geteprop(x, 3, 4, "f2") == 2.0

         seteprop!(x, 5=>6, 2.0, "f2")
         @test geteprop(x, 5=>6, "f2") == 2.0

         seteprop!(x, elist, fill(2.0, 10), "f2")
         @test all(geteprop(x, elist, "f2") .== 2.0)

         seteprop!(x, elist, "3", "f3")
         @test all(geteprop(x, elist, "f3") .== "3")

         seteprop!(x, :, Colon(), "f4")
         @test all(geteprop(x, :, "f4") .== Colon())

         seteprop!(x, :, '5', "f5")
         @test all(geteprop(x, :, "f5") .== '5')

         # Adjacency Tests
         @test addvertex!(x) == nothing
         @test addvertex!(x, 2) == nothing
         @test addedge!(x, 11, 12) == nothing
         @test addedge!(x, EdgeID[12=>13, 11=>13]) == nothing

         # Remove vertices and edges
         rmvertex!(x, 13) == nothing
         @test nv(x) == 12

         rmedge!(x, 11, 12) == nothing
         rmvertex!(x, [11,12]) == nothing
         @test nv(x) == 10
         @test ne(x) == 90
      end
   end
end
