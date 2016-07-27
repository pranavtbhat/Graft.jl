################################################# FILE DESCRIPTION #########################################################

# This file contains tests for queries.

############################################################################################################################

# Tests for VertexDescriptor
for PM in subtypes(PropertyModule)
   for typ in [Any,TestType]
      gtype = Graph{SparseMatrixAM,PM{typ,typ}}
      @testset "VertexDescriptor tests for $gtype" begin
         g = completegraph(gtype, 10)
         ls = map(string, 1:10)
         setlabel!(g, ls)

         V, = g

         # Iteration
         @test length(V) == 10
         @test size(V) == (10,)

         @test start(V) == 1
         @test endof(V) == 10
         @test done(V, 11) == true

         @test [v for v in V] == ls


         # Getindex
         v1 = V["1"]
         @test isa(v1, VertexDescriptor)
         @test length(v1) == 1
         @test v1.props == V.props

         v38 = V[3:8]
         @test isa(v38, VertexDescriptor)
         @test length(v38) == 6
         @test v38.props == V.props

         @test V[:] == V

         # Get/Set
         val = rand(Int, 10)
         set!(V, val, "f1")
         @test get(V, "f1") == val

         val = rand(5)
         set!(V[1:5], val, "f2")
         @test get(V[1:5], "f2") == val

         val = randstring()
         set!(V["5"], val, "f3")
         @test get(V["5"], "f3") == val


         # Map
         @test map(v->v, V) == ls

         # Map!
         map!(v->false, V, "f4")
         @test all(get(V, "f4") .== false)

         # Select
         @test select(V, "f1", "f2", "f3").props == ["f1", "f2", "f3"]
      end

      @testset "Query tests for $gtype" begin
         g = completegraph(gtype, 10)
         V, = g

         # Label substitution
         @test (@query V v) == 1:10

         # getfield/setfield
         @query V v.f1 = 1
         @test all(@query V v.f1 == 1)

         # Adjacency substitution
         @test (@query V[5] g[v]) == [V.g[5]]

         # Function substitution
         @query V v.f1 = zero(Int)
         @test (@query V v.f1) == zeros(Int, 10)
      end
   end
end

for PM in subtypes(PropertyModule)
   for typ in [Any,TestType]
      gtype = Graph{SparseMatrixAM,PM{typ,typ}}
      @testset "EdgeDescriptor tests for $gtype" begin
         g = completegraph(gtype, 10)
         ls = map(string, 1:10)
         setlabel!(g, ls)

         _,E = g

         # Iteration
         @test length(E) == 90
         @test size(E) == (90,)

         @test [e for e in E] == encode(g, edges(g))

         # Getindex
         e1 = E[1]
         @test isa(e1, EdgeDescriptor)
         @test length(e1) == 1
         @test e1.props == E.props

         e3060 = E[30:60]
         @test isa(e3060, EdgeDescriptor)
         @test length(e3060) == 31
         @test e3060.props == E.props

         @test E[:] == E

         # Get/Set
         val = collect(1:90)
         set!(E, val, "f1")
         get(E, "f1") == val

         val = rand(45)
         set!(E[1:45], val, "f2")
         @test get(E[1:45], "f2") == val

         val = randstring()
         set!(E[45], val, "f3")
         @test get(E[45], "f3") == val

         # Map
         @test all(map((u,v)->false, E) .== false)

         # Map!
         map!((u,v)->true, E[:], "f4")
         @test all(get(E[:], "f4") .== true)

         # Select
         @test select(E, "f1", "f2", "f3").props == ["f1", "f2", "f3"]
      end

      @testset "Query tests for $gtype" begin
         g = completegraph(gtype, 10)
         V,E = g

         # Label substitution
         (@query E[1:10] u) == ones(Int, 10)
         (@query E[1:10] v) == collect(1:10)

         # getfield/setfield
         @query E e.f1 = 1
         @test all(@query(E, e.f1 == 1))

         @query E u.f1 = 1
         @test all(@query E u.f1 == 1)

         @query E v.f2 = 1.0
         @test all(@query(E, v.f2 == 1.0))

         @query E e.f2 = u.f1 + v.f2
         @test all(@query E e.f2 == 2.0)

         # Function substitution
         @query E e.f1 = zero(Int)
         @test all(@query E e.f1 == 0)
      end
   end
end
