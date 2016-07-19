################################################# FILE DESCRIPTION #########################################################

# This file contains tests for queries.

############################################################################################################################

# Tests for VertexDescriptor
for PM in subtypes(PropertyModule)
   for typ in [Any,TestType]
      propmod = PM{typ,typ}
      @testset "VertexDescriptor tests for Graph{SparseMatrixAM,$PM}" begin
         V, = Graph{SparseMatrixAM,propmod}(10,90)

         # Iteration
         @test length(V) == 10
         @test size(V) == (10,)
         @test start(V) == false
         @test endof(V) == 10
         # @test next(V, 1) == ((1, Dict()), 2)
         @test done(V, 11) == true

         # Getindex
         v1 = V[1]
         @test isa(v1, VertexDescriptor)
         @test length(v1) == 1
         @test v1.props == V.props

         v38 = V[3:8]
         @test isa(v38, VertexDescriptor)
         @test length(v38) == 6
         @test v38.props == V.props

         @test V[:] == V

         # Setindex
         V["f1"] = 1:10
         V[1:5]["f4"] = true
         V[5]["f3"] = "Middle"

         # Get
         @test all(get(V, "f1") .== 1:10)
         @test get(V[1:5], "f4") == trues(5)
         @test get(V[5], "f3") == "Middle"

         # Map! Function based
         map!(v->v, V, "f1")
         @test all(get(V, "f1") .== 1:10)

         map!(v->0.0, V[:], "f2")
         @test get(V[:], "f2") == zeros(10)

         # Map! query based
         map!("v.f2 < v.f1", V[1:5], "f4")
         @test get(V[1:5], "f4") == trues(5)

         # Map function based
         @test map(v->1, V) == fill(1, 10)

         # Map query based
         @test map("v.f1 + 5", V) == get(V, "f1") .+ 5

         # Select
         @test select(V, "f1", "f2", "f3").props == ["f1", "f2", "f3"]
         cV = V[:]
         select!(cV, "f1", "f2")
         @test cV.props == ["f1", "f2"]
      end
   end
end

for PM in subtypes(PropertyModule)
   for typ in [Any,TestType]
      propmod = PM{typ,typ}
      @testset "EdgeDescriptor tests for Graph{SparseMatrixAM,$PM}" begin
         V,E = Graph{SparseMatrixAM,propmod}(10,90)

         # Iteration
         @test length(E) == 90
         @test size(E) == (90,)

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

         # Setindex
         E["f1"] = 1:90
         E[1:45]["f4"] = true
         E[45]["f3"] = "Middle"

         # Get
         @test all(get(E, "f1") .== 1:90)
         @test get(E[1:45], "f4") == trues(45)
         @test get(E[45], "f3") == "Middle"

         # Map! function based
         map!((u,v)->1, E, "f1")
         @test get(E, "f1") == fill(1, 90)

         map!((u,v)->5.0, E[:], "f2")
         @test get(E[:], "f2") == fill(5.0, 90)


         # Map! query based
         map!("e.f1 < e.f2", E[:], "f4")
         @test get(E, "f4") == trues(90)


         # Map function based
         @test map((u,v)->5, E) == fill(5, 90)
         @test map("e.f1 + 1", E) == fill(2, 90)

         # Select
         @test select(E, "f1", "f2", "f3").props == ["f1", "f2", "f3"]
         cE = E[:]
         select!(cE, "f1", "f2")
         @test cE.props == ["f1", "f2"]
      end
   end
end
