############################################################################################################################

# This file contains tests for EdgeIter

############################################################################################################################

function edge_iter_sanity_test(ne::Int, eit::EdgeIter)
   @test eit == eit
   @test length(eit) == ne
   @test size(eit) == (ne,)
   @test eit == copy(eit)
   @test deepcopy(eit) == deepcopy(eit)
   @test issorted(eit) == true
   @test eltype(eit) == EdgeID
   @test EdgeIter(collect(eit)) == eit
end

function edge_iter_iteration_test(ne::Int, eit::EdgeIter)
   @test start(eit) == 1
   @test endof(eit) == ne
   @test eachindex(eit) == 1 : ne
   @test [e for e in eit] == collect(eit) == map(EdgeID, eit.us, eit.vs)
end

function edge_iter_getindex_test(ne::Int, eit::EdgeIter)
   @test eit[1] == first(eit)
   @test eit[1:ne] == eit
   @test eit[:] == eit
end

@testset "EdgeIter Construction" begin
   x = completeindxs(10)

   eit1 = EdgeIter(x)
   edge_iter_sanity_test(90, eit1)
   edge_iter_iteration_test(90, eit1)
   edge_iter_getindex_test(90, eit1)

   eit2 = EdgeIter(x, 1)
   edge_iter_sanity_test(9, eit2)
   edge_iter_iteration_test(9, eit2)
   edge_iter_getindex_test(9, eit2)
   @test eit2 == eit1[1:9]

   eit3 = EdgeIter(x, 1:5)
   edge_iter_sanity_test(45, eit3)
   edge_iter_iteration_test(45, eit3)
   edge_iter_getindex_test(45, eit3)
end
