################################################# FILE DESCRIPTION #########################################################

# This file contains tests for PropertyModules
 
############################################################################################################################


for PM in subtypes(PropertyModule)
   for typ in [Any,TestType]
      @testset "Filter test for $PM" begin
         g = Graph{SparseMatrixAM,PM{typ,typ}}(10,90)

         # Only vertex filtering
         setvprop!(g, :, v->v, "f1")
         @test nv(filter(g, "v.f1 <= 5")) == 5
         @test nv(filter(g, "v.f1 > 7")) == 3      

         setvprop!(g, :, v->"hi", "f3")
         @test nv(filter(g, "v.f3 == hi")) == 10

         # Mutliple conditions
         @test nv(filter(g, "v.f1 < 7", "v.f1 > 3")) == 3
         @test nv(filter(g, "v.f1 <= 10", "v.f3 == hi")) == 10

         # Only edge filtering
         seteprop!(g, :, (u,v)->u, "f1")
         @test ne(filter(g, "e.f1 <= 5")) == 45

         seteprop!(g, :, (u,v)->Float64(u+v), "f2")
         @test ne(filter(g, "e.f2 <= 10")) == 40

         # Multiple conditions
         @test ne(filter(g, "e.f1 <= 5", "e.f2 <= 10")) == 30
         @test ne(filter(g, "e.f1 <= 9", "e.f1 >= 5")) == 45

         # Mixed filtering
         h = filter(g, "v.f1 <= 5", "e.f2 <= 10")
         @test nv(h) == 5
         @test ne(h) == 20
      end
   end
end