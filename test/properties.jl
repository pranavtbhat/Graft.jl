################################################# FILE DESCRIPTION #########################################################

# This file contains tests for PropertyModules
 
############################################################################################################################


for PM in subtypes(PropertyModule)
   @testset "Properties Interface for $PM" begin
      g = Graph{SparseMatrixAM,PM}(10,90)

      # Setvprop
      setvprop!(g, 1, Dict("p1"=>1))
      setvprop!(g, 1:10, [Dict("p2"=>2) for i in 1:10])
      setvprop!(g, :, [Dict("p2"=>2) for i in 1:10])
      setvprop!(g, 2, 1, "p1")
      setvprop!(g, 1:10, 3 * ones(Int, 10), "p3")
      setvprop!(g, 1:10, v->4, "p4")
      setvprop!(g, :, 5 * ones(Int, 10), "p5")
      setvprop!(g, :, v->6, "p6")

      # Getvprop
      @test getvprop(g, 1) == ["p$i"=>i for i in 1:6]
      @test getvprop(g, 3:10) == [Dict(["p$i"=>i for i in 2:6]...) for j in 3:10]
      @test getvprop(g, 1, "p1") == 1
      @test getvprop(g, 1:10, "p3") == 3 * ones(Int, 10)
      @test getvprop(g, 1:10, "p4") == 4 * ones(Int, 10)
      @test getvprop(g, 1:10, "p5") == 5 * ones(Int, 10)
      @test getvprop(g, 1:10, "p6") == 6 * ones(Int, 10)

      # List v prop
      @test issubset(listvprops(g), ["p$i" for i in 1:6])

      elist = collect(edges(g))[11:20]
      dlist = [Dict("p2"=>2) for i in 1:10]

      # Seteprop
      seteprop!(g, 1, 2, Dict("p1"=>1))
      seteprop!(g, 2=>3, Dict("p1"=>1))
      seteprop!(g, elist, dlist)
      seteprop!(g, 3, 4, 2, "p2")
      seteprop!(g, 5=>6, 2, "p2")
      seteprop!(g, elist, 3 * ones(Int, 10), "p3")
      seteprop!(g, elist, (u,v)->4, "p4")
      

      # Geteprop
      @test issubset(Dict("p1"=>1), geteprop(g, 1, 2))
      @test issubset(Dict("p1"=>1), geteprop(g, 2=>3))
      @test geteprop(g, 3, 4, "p2") == 2
      @test geteprop(g, 5=>6, "p2") == 2
      @test geteprop(g, elist, "p3") == 3 * ones(Int, 10)
      @test geteprop(g, elist, "p4") == 4 * ones(Int, 10)

      # Rewrite
      seteprop!(g, :, 5 * ones(Int, 90), "p5")
      seteprop!(g, :, (u,v)->6, "p6")

      @test geteprop(g, :, "p5") == 5 * ones(Int, 90)
      @test geteprop(g, :, "p6") == 6 * ones(Int, 90)
      
      # Adjacency Tests
      @test addvertex!(g) == nothing
      @test addvertex!(g, 2) == nothing
      @test addedge!(g, 11, 12) == nothing
      @test addedge!(g, EdgeID[12=>13, 11=>13]) == nothing

      # Change data type test
      setvprop!(g, 11, "p1", 1)
      @test setvprop!(g, 12, "p1", "1") == nothing

      seteprop!(g, 11, 12, "1", "p1")
      @test seteprop!(g, 11, 13, 1, "p1") == nothing


      # Remove vertices and edges
      rmvertex!(g, 13) == nothing
      @test nv(g) == 12

      rmedge!(g, 11, 12) == nothing
      rmvertex!(g, [11,12]) == nothing
      @test nv(g) == 10
      @test ne(g) == 90


   end
end