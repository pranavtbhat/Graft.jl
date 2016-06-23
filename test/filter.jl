################################################# FILE DESCRIPTION #########################################################

# This file contains tests for PropertyModules
 
############################################################################################################################


for PM in subtypes(PropertyModule)
   @testset "Filter test for $PM" begin
      g = Graph{SparseMatrixAM,PM}(10, 90)

      # Only vertex filtering
      setvprop!(g, :, v->v, "id")
      @test nv(filter(g, "v.id <= 5")) == 5
      @test nv(filter(g, "v.id > 7")) == 3      

      setvprop!(g, :, v->"hi", "txt")
      @test nv(filter(g, "v.txt == hi")) == 10

      # Mutliple conditions
      @test nv(filter(g, "v.id < 7", "v.id > 3")) == 3
      @test nv(filter(g, "v.id <= 10", "v.txt == hi")) == 10

      # Only edge filtering
      seteprop!(g, :, (u,v)->u, "id")
      @test ne(filter(g, "e.id <= 5")) == 45

      seteprop!(g, :, (u,v)->u+v, "weight")
      @test ne(filter(g, "e.weight <= 10")) == 40

      # Multiple conditions
      @test ne(filter(g, "e.id <= 5", "e.weight <= 10")) == 30
      @test ne(filter(g, "e.id <= 9", "e.id >= 5")) == 45

      # Mixed filtering
      h = filter(g, "v.id <= 5", "e.weight <= 10")
      @test nv(h) == 5
      @test ne(h) == 20
   end
end