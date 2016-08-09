################################################# FILE DESCRIPTION #########################################################

# This file contains tests for the Mutation API

############################################################################################################################

@testset "Mutation Addvertex" begin
   g = completegraph(10)

   # Set vertex properties
   setvprop!(g, :, 1:10, :p1)
   setvprop!(g, :, 1:10, :p2)

   # Set edge properties
   seteprop!(g, :, 1:90, :p1)
   seteprop!(g, :, 1:90, :p2)

   g1 = deepcopy(g)
   # Addvertex without labels
   # Check for NA row
   # Check for type of LabelMap
   @test addvertex!(g1) == 11
   @test isequal(getvprop(g1, 11, :p1), NA)
   @test isequal(getvprop(g1, 11, :p2), NA)
   @test isa(g1.lmap, IdentityLM)

   g2 = deepcopy(g)
   # Addvertex with label
   # Check for NA row
   # Check for type of LabelMap
   @test addvertex!(g2, 15) == 11
   @test isequal(getvprop(g2, 11, :p1), NA)
   @test isequal(getvprop(g2, 11, :p2), NA)
   @test isa(g2.lmap, DictLM)

   g3 = deepcopy(g)
   # Addvertex with existing label
   # Check for no new row
   # Check for type of LabelMap
   @test addvertex!(g3, 10) == 10
   @test size(g3.vdata) == (10,2)
   @test isa(g3.lmap, IdentityLM)

   g4 = deepcopy(g)
   g4 + 11
   @test g4 == g1

   g5 = deepcopy(g)
   g5 + 15
   @test g5 == g2
end


@testset "Mutation Addedge" begin
   g = completegraph(10)

   # Set vertex properties
   setvprop!(g, :, 1:10, :p1)
   setvprop!(g, :, 1:10, :p2)

   # Set edge properties
   seteprop!(g, :, 1:90, :p1)
   seteprop!(g, :, 1:90, :p2)

   g1 = deepcopy(g)
   # Addedge 1=>1
   # Check for NA row at the END.
   # Check for mapping
   @test addedge!(g1, 1=>1) == true
   @test g1.indxs[1=>1] == 91

   g2 = deepcopy(g)
   g2[1] = 1
   @test g2 == g1

   g3 = deepcopy(g)
   g3[1] = [1]
   g3[5] = [5]
   g3[10] = [10]
   @test g3.indxs[[1=>1, 5=>5, 10=>10]] == [91, 92, 93]
end


@testset "Mutation Rmvertex" begin
   g = completegraph(10)
   setlabel!(g, collect(1:10))

   # Set vertex properties
   setvprop!(g, :, 1:10, :p1)
   setvprop!(g, :, 1:10, :p2)

   # Set edge properties
   seteprop!(g, :, 1:90, :p1)
   seteprop!(g, :, 1:90, :p2)

   g1 = deepcopy(g)
   # Remove vertex 10
   # Check for size of vdata
   # Check for edata entries
   rmvertex!(g1, 10)
   @test size(g1.vdata) == (9, 2)
   @test size(g1.edata) == (72, 2)

   g2 = deepcopy(g)
   g2 - 10
   @test g2 == g1

   g3 = deepcopy(g)
   # Remove vertices 5, 8
   # Check for size of vdata
   # Check for edata entries
   rmvertex!(g3, [5,8])
   @test nv(g3) == 8
   @test size(vdata(g3)) == (8,2)
   @test size(edata(g3)) == (56,2)

   g4 = deepcopy(g)
   g4 - [5,8]
   @test g4 == g3
end

@testset "Mutation Rmedge" begin
   g = Graph(completeindxs(10))
   # Set edge properties
   seteprop!(g, :, 1:90, :p1)
   seteprop!(g, :, 1:90, :p2)

   g1 = deepcopy(g)
   # Remove edge 1=>2
   # Check for size of edata
   # Check indexing table
   rmedge!(g1, 1=>2)
   @test size(g1.edata) == (89, 2)
   @test g1.indxs.nzval == collect(1:89)
   @test hasedge(g1, 1=>2) == false

   g2 = deepcopy(g)
   # Remove edges 1=>2, 5=>4, 10=>9
   # Check for size of edata
   # Check indexing table
   rmedge!(g2, 1=>2)
   rmedge!(g2, 5=>4)
   rmedge!(g2, 10=>9)
   @test size(g2.edata) == (87,2)
   @test g2.indxs.nzval == collect(1:87)
   @test hasedge(g1, 1=>2) == false
   @test hasedge(g2, 5=>4) == false
   @test hasedge(g2, 10=>9) == false
end
