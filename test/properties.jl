################################################# FILE DESCRIPTION #########################################################

# This file contains tests for PropertyModules

############################################################################################################################


for PM in subtypes(PropertyModule)
   for typ in [Any,TestType]
      pmtype = PM{typ,typ}
      @testset "Properties Interface for $pmtype" begin
         x = completegraph(Graph{SparseMatrixAM,pmtype}, 10)
         d = Dict("f1"=>1, "f2"=>0.0, "f3"=>"3", "f4"=>nothing, "f5"=>'5')
         es = collect(edges(x))

         ###
         # VERTEX TESTS
         ###
         # Unit Single
         setvprop!(x, 1, 1, "f1")
         @test getvprop(x, 1, "f1") == 1

         # Multi Single
         arr = rand(4)
         setvprop!(x, 3:6, arr, "f2")
         @test getvprop(x, 3:6, "f2") == arr

         # All Single
         arr = broadcast(randstring, fill(5, 10))
         setvprop!(x, 1:10, arr, "f3")
         @test getvprop(x, :, "f3") == arr

         # Multi Function
         arr = map(Symbol, 2:7)
         setvprop!(x, 2:7, x->Symbol(x), "f4")
         @test getvprop(x, 2:7, "f4") == arr

         # All Function
         arr = map(Char, 1:10)
         setvprop!(x, :, x->Char(x), "f5")
         @test getvprop(x, :, "f5") == arr

         # Unit Dict
         setvprop!(x, 1, d)
         @test getvprop(x, 1) == d

         ###
         # EDGE TESTS
         ###
         # Unit Single
         seteprop!(x, es[1], 1, "f1")
         @test geteprop(x, es[1], "f1") == 1

         # Multi Single
         arr = rand(47)
         seteprop!(x, es[17:63], arr, "f2")
         @test geteprop(x, es[17:63], "f2") == arr

         # All Single
         arr = broadcast(randstring, fill(2, 90))
         seteprop!(x, :, arr, "f3")
         @test geteprop(x, :, "f3") == arr

         # Multi Function
         arr = broadcast(Symbol, 63:88)
         i = 62
         seteprop!(x, es[63:88], (u,v)->Symbol(i+=1), "f4")
         @test geteprop(x, es[63:88], "f4") == arr

         # All Function
         arr = map(Char, 1:90)
         i = 0
         seteprop!(x, :, (u,v)->Char(i+=1), "f5")
         @test geteprop(x, :, "f5") == arr

         # Adjacency Tests
         addvertex!(x)
         addvertex!(x)
         addvertex!(x)
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
