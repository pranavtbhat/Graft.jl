################################################# FILE DESCRIPTION #########################################################

# This file contains tests for edge indexing

############################################################################################################################

@testset "SparseMatrixCSC Generation" begin
   Nv = 10
   Ne = 90

   x = randindxs(Nv, Ne)
   @test size(x) == (Nv,Nv)
   @test Ne / 2 <= nnz(x) <= 2 * Ne
   @test nonzeros(x) == collect(1 : nnz(x))

   x = completeindxs(Nv)
   @test size(x) == (Nv,Nv)
   @test nnz(x) == Nv * (Nv - 1)
   @test nonzeros(x) == collect(1 : nnz(x))
end

@testset "SparseMatrixCSC Indexing" begin
   x = completeindxs(10)
   e = 1=>2
   es = EdgeID[1=>2, 3=>6, 4=>7, 5=>9]
   eit = EdgeIter(4, [1,3,4,5], [2,6,7,9])

   @test x[e] == 1
   @test x[es] == [1, 23, 33, 44]
   @test x[eit] == [1, 23, 33, 44]

   x[e] = 2
   @test x[e] == 2

   x[es] = 5
   @test x[es] == [5, 5, 5, 5]
   @test x[eit] == [5, 5, 5, 5]

   x[eit] = 7
   @test x[es] == [7, 7, 7, 7]
   @test x[eit] == [7, 7, 7, 7]

   x[es] = [1,2,3,4]
   @test x[es] == [1, 2, 3, 4]
   @test x[eit] == [1, 2, 3, 4]

   x[eit] = [4, 3, 2, 1]
   @test x[es] == [4, 3, 2, 1]
   @test x[eit] == [4, 3, 2, 1]
end

@testset "SparseMatrixCSC Adjacency" begin
   x = completeindxs(10)
   v = rand(1:10)
   vs = rand(1:10, 5)
   adj = setdiff(1:10, v)

   @test fadj(x, v) == adj
   @test fadj!(x, v, zeros(Int, 9)) == adj

   @test indegree(x, v) == 9
   @test indegree(x, vs) == [indegree(x, v) for v in vs]
   @test indegree(x) == fill(9, 10)

   @test outdegree(x, v) == 9
   @test outdegree(x, vs) == [outdegree(x, v) for v in vs]
   @test outdegree(x) == fill(9, 10)
end

@testset "SparseMatrixCSC Mutation" begin
   x = completeindxs(10)

   y = addvertex!(x)
   @test nv(y) == 11
   @test EdgeIter(x) == EdgeIter(y)

   y,erows = rmvertex!(y, 11)
   @test x == y
   @test erows == Int[]

   e = 1=>1
   es = EdgeID[2=>2, 3=>3, 4=>4, 5=>5]

   addedge!(x, e, 91)
   @test x[e] == 91

   rmedge!(x, e)
   @test x[e] == 0

   addedge!(x, es, [92,93,94,95])
   @test x[es] == [92,93,94,95]

   rmedge!(x, es)
   @test x[es] == [0,0,0,0]
end

@testset "SparseMatrixCSC Subgraph" begin
   x = completeindxs(10)
   vs = 1:5
   eit = EdgeIter(x)
   terows = [1,2,3,4,10,11,12,13,19,20,21,22,28,29,30,31,37,38,39,40]

   x1,erows = subgraph(x, vs)
   @test nv(x1) == 5
   @test ne(x1) == 20
   @test erows == terows

   x2,erows = subgraph(x, eit)
   @test nv(x2) == 10
   @test ne(x2) == 90
   @test eit == EdgeIter(x2)
   @test erows == collect(1:90)

   x3,erows = subgraph(x, vs, eit)
   @test nv(x3) == 5
   @test ne(x3) == 20
   @test x1 == x3
   @test erows == terows
end
