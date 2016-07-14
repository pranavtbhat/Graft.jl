################################################# FILE DESCRIPTION #########################################################

# This file contains tests for utils

############################################################################################################################

@testset "Tests for delete_entry" begin
   x = sprand(10, 10, 1.0)

   ParallelGraphs.delete_entry!(x, 5, 5)
   @test x[5,5] == 0
   ParallelGraphs.delete_entry!(x, 6, 9)
   @test x[9,6] == 0
   ParallelGraphs.delete_entry!(x, 2, :)
   @test nnz(x[:,2]) == 0
   ParallelGraphs.delete_entry!(x, 7, :)
   @test nnz(x[:,7]) == 0
end

@testset "Tests for remove_cols" begin
   x = sprand(10, 10, 1.0)

   x = ParallelGraphs.remove_cols(x, [1])
   @test size(x) == (9,9)
   x = ParallelGraphs.remove_cols(x, [3,4,5])
   @test size(x) == (6,6)
end

@testset "Tests for init_spmx" begin
   x = sprandbool(10, 10, 1.0)
   es = map(i->reverse(EdgeID(ind2sub(x, i)...)), 1:100)
   @test x == ParallelGraphs.init_spmx(10, es, x.nzval)
end

@testset "Tests for splice_matrix" begin
   x = sprandbool(10, 10, 1.0)
   es = map(i->reverse(EdgeID(ind2sub(x, i)...)), 1:100)
   @test x == ParallelGraphs.splice_matrix(x, es)
end


for AM in subtypes(AdjacencyModule)
   for PM in subtypes(PropertyModule)
      for typ in [Any,TestType]
         @testset "Tests for Display of $(Graph{AM,PM{typ,typ}})" begin
            V,E = Graph{AM,PM{typ,typ}}(10,90)

            # Vertex Properties
            map!(v->rand(Int), V, "f1")
            map!(v->rand(), V, "f2")
            map!(v->randstring(), V, "f3")
            map!(v->rand(Bool), V, "f4")
            map!(v->'0', V, "f5")

            # Edge properties
            map!((u,v)->rand(Int), E, "f1")
            map!((u,v)->rand(), E, "f2")
            map!((u,v)->randstring(), E, "f3")
            map!((u,v)->rand(Bool), E, "f4")
            map!((u,v)->'0', E, "f5")

            # Labels
            setlabel!(V.g, "f3")

            # Drawing
            ss = IOBuffer()
            println(ss, V)
            println(ss, E)
         end
      end
   end
end
