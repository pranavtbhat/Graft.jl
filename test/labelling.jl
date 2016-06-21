################################################# FILE DESCRIPTION #########################################################

# This file contains tests for LabelModule
 
############################################################################################################################


@testset "Label Module" begin
   g = parsegraph("testgraph.txt", :TGF, SparseGraph)

   labels = ["$i" for i in vertices(g)]
   
   # Enable Labelling
   @test setlabel!(g, labels) == nothing

   @test setlabel!(g, 1, "v1") == nothing
   @test setlabel!(g, 2, "v2") == nothing

   @test resolve(g, "v1") == 1
   @test encode(g, 1) == "v1"

   @test resolve(g, "v1"=>"v2") == (1=>2)
   @test encode(g, 1=>2) == ("v1"=>"v2")

   @test setlabel!(g, labels) == nothing
   @test g[:] == labels

   h = subgraph(g, 1:5)
   @test h[:] == labels[1:5]
end


