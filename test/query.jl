################################################# FILE DESCRIPTION #########################################################

# This file contains tests for queries.

############################################################################################################################

for PM in subtypes(PropertyModule)
   for typ in [Any,TestType]
      @testset "Query tests for Graph{SparseMatrixAM,$PM}" begin
         
         g = Graph{SparseMatrixAM,PM{typ,typ}}(10,90)

         labels = ["$i" for i in 1:10]
         setlabel!(g, labels)

         @test g[:] == labels
         
         @test length(g[=>]) == ne(g)

         @test g["1"=>:] == ["$i" for i in 2:10]

         # Vertex Properties
         g["1", "f1"] = 1
         g["1"] = Dict("f4"=>Colon(), "f5"=>'5')
         g[:, "f2"] = fill(2.0, 10)
         g[:,:] = [Dict("f3"=>"3") for i in 1:10]

         if typ == Any
            @test g["1"] == Dict("f1"=>1, "f2"=>2.0, "f3"=>"3", "f4"=>Colon(), "f5"=>'5')
         else
            @test g["1"] == TestType(1, 2.0, "3", Colon(), '5')
         end

         @test g[:,"f2"] == fill(2.0, 10)
         @test g[:,:] == getvprop(g, :)

         # Edge Properties
         g["1"=>"2", "f1"] = 1
         g["1"=>"2"] = Dict("f2"=>2.0)
         g[=>, "f3"] = fill("3", 90)
         g[=>, :] = [Dict("f4"=>Colon(), "f5"=>'5') for i in 1:90]

         if typ == Any
            @test g["1"=>"2"] == Dict("f1"=>1, "f2"=>2.0, "f3"=>"3", "f4"=>Colon(), "f5"=>'5')
         else
            @test g["1"=>"2"] == TestType(1, 2.0, "3", Colon(), '5')
         end

         @test g["1"=>"2", "f1"] == 1
         @test g[=>, "f3"] == fill("3", 90)
         @test g[=>, :] == geteprop(g, :)
      end
   end
end
