################################################# FILE DESCRIPTION #########################################################

# This file contains tests for PropertyModules

############################################################################################################################


for PM in subtypes(PropertyModule)
   for typ in [Any,TestType]
      propmod = PM{typ,typ}
      @testset "Filter test for $propmod" begin
         V,E = Graph{SparseMatrixAM,propmod}(10,90)

         V["f1"] = 1 : 10
         V["f2"] = 10.0 : -1.0 : 1.0

         E["f1"] = 1 : 90
         E["f2"] = 90.0 : -1.0 : 1.0

         @test V[1:5] == filter(V, "v.f1 <= 5")
         @test V[3:8] == filter(V, "v.f1 <= 8 && v.f1 >= 3")
         @test V[:] == filter(V, "v.f1 == v.f1")
         @test V[5] == filter(V, "v.f1 == v.f2")
         @test V[1:5] == filter(V, "v.f1 <= v.f2")


         @test E[1:45] == filter(E, "e.f1 <= 45")
         @test E[30:60] == filter(E, "e.f1 <= 60 && e.f1 >= 30")
         @test E[:] == filter(E, "e.f1 == e.f1")
         @test E[46:90] == filter(E, "e.f2 <= e.f1")

         V[7:10]["f3"] = "hello"
         @test V[7:10] == filter(V, "v.f3 == hello")

         E[7:10]["f3"] = "hello"
         @test E[7:10] == filter(E, "e.f3 == hello")
      end
   end
end
