################################################# FILE DESCRIPTION #########################################################

# This file contains tests for PropertyModules

############################################################################################################################


for PM in subtypes(PropertyModule)
   for typ in [Any,TestType]
      gtype = Graph{SparseMatrixAM,PM{typ,typ}}
      @testset "Filter test for $gtype" begin
         V,E = completegraph(gtype, 10)

         ###
         # VERTEX
         ###
         set!(V, 1:10, "f1")
         @test V[1:5] == (@filter V v.f1 <= 5)
         @test V[3:7] == (@filter V 3 <= v.f1 <= 7)
         @test V[3:7] == (@filter V 3 <= v.f1 && v.f1 <= 7)
         @test V[[2,3,7,8]] == (@filter V 2 <= v.f1 <= 3 || 6 < v.f1 < 9)

         set!(V, 1.0:1.0:10.0, "f2")
         @test V == (@filter V v.f1 == v.f2)

         set!(V, "1", "f3")
         @test V == (@filter V v.f3 == "1")


         ###
         # EDGE
         ###
         set!(E, 1:90, "f1")
         @test E[1:45] == (@filter E e.f1 <= 45)
         @test E[30:60] == (@filter E 30 <= e.f1 <= 60)
         @test E[30:60] == (@filter E 30 <= e.f1 && e.f1 <= 60)
         @test E[[31,32,71,72]] == (@filter E 30 < e.f1 < 33 || 70 < e.f1 < 73)

         set!(E, 1.0:1.0:90.0, "f2")
         @test E == (@filter E e.f1 == e.f2)

         set!(E, "1", "f3")
         @test E == (@filter E v.f3 == "1")
      end
   end
end
