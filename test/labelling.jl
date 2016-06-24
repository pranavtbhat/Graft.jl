################################################# FILE DESCRIPTION #########################################################

# This file contains tests for LabelModule
 
############################################################################################################################


@testset "Label Module" begin
   g = SparseGraph(10, 90)

   labels = ["$i" for i in 1:10]
   @test setlabel!(g, labels) == nothing
   @test g[:] == labels
   
   h = subgraph(g, 1:5)
   @test h[:] == labels[1:5]

   @test rmvertex!(g, 5) == nothing
   @test resolve(g, "6") == 5

   @test rmvertex!(g, [2,6,9]) == nothing
   @test resolve(g, ["1", "3", "4", "8", "9"]) == [1, 2, 3, 5, 6]

   @test addvertex!(g) == nothing
   @test addvertex!(g, 3) == nothing

   # Disable labelling
   setlabel!(g) == nothing
   @test resolve(g, 1) == 1 

   # Enable labelling
   setlabel!(g, labels)

   @test setlabel!(g, 1, "v1") == nothing
   @test setlabel!(g, 2, "v2") == nothing

   @test resolve(g, "v1") == 1
   @test encode(g, 1) == "v1"

   @test resolve(g, "v1"=>"v2") == (1=>2)
   @test encode(g, 1=>2) == ("v1"=>"v2")
end


