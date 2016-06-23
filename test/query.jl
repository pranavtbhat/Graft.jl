################################################# FILE DESCRIPTION #########################################################

# This file contains tests for queries.

############################################################################################################################

for PM in subtypes(PropertyModule)
   @testset "Query tests for Graph{SparseMatrixAM,$PM}" begin
      g = Graph{SparseMatrixAM,PM}(10, 90)
      labels = ["$i" for i in 1:10]
      setlabel!(g, labels)

      @test g[:] == labels
      
      @test length(g[=>]) == ne(g)

      @test g["1"=>:] == ["$i" for i in 2:10]

      # Vertex Properties
      g["1", "p1"] = 1
      g["1"] = Dict("p4"=>4, "p5"=>5)
      g[:, "p2"] = 2 * ones(Int, 10)
      g[:,:] = [Dict("p3"=>3) for i in 1:10]

      @test g["1"] == ["p$i" => i for i in 1:5]
      @test g[:,"p2"] == 2 * ones(Int, 10)
      @test g[:,:] == getvprop(g, :)


      g["1"=>"2", "p1"] = 1
      g["1"=>"2"] = Dict("p2"=>2)
      g[=>, "p3"] = 3 * ones(Int, 90)
      g[=>, :] = [Dict("p4"=>4) for i in 1:90]

      @test g["1"=>"2"] == ["p$i" => i for i in 1:4]
      @test g["1"=>"2", "p1"] == 1
      @test g[=>, "p3"] == 3 *  ones(Int, 90)
      @test g[=>, :] == geteprop(g, :)
   end
end
