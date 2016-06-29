using ParallelGraphs
using JLD
using BenchmarkTools

import BenchmarkTools: prettytime, prettymemory, prettydiff

type TestType
   f1::Int
   f2::Float64
   f3::ASCIIString
   f4::Any
   f5::Char
end


cd(joinpath(Pkg.dir("ParallelGraphs"), "benchmarks"))


function tune_suite(suite, tune_file)
   if isfile(tune_file)
      println("Using benchmark tuning data in $tune_file")
      loadparams!(suite, JLD.load(tune_file, "suite"), :evals, :samples)
   else
      println("Creating benchmark tuning file $tune_file")
      tune!(suite)
      JLD.save(tune_file, "suite", params(suite))
   end
end

function save_suite(result, save_file)
   if save_file != ""
      println("Saving results to $save_file")
      JLD.save(save_file, "result", result)
   end
end

function compare_suite(result, compare_file)
   if isfile(compare_file)
      println("Comparing with results in $compare_file")
      reference_results = JLD.load(compare_file, "result")
      display_compare(judge(reference_results, result))
   end
end

function display(result)
   @printf "%-30s | %-12s | %-12s | %-12s\n" "Test" "Time Taken" "Memory" "GCTime"
   println(join(['\u2014' for i in 1:70]))
   for (key,item) in result
      @printf "%-30s | %-12s | %-12s | %-12s\n" key[16:end] prettytime(item.time) prettymemory(item.memory) prettytime(item.gctime)
   end
   println()
   nothing
end

function display_compare(result)
   @printf "%-30s | %-12s | %-12s\n" "Test" "Time Taken" "Memory"
   println(join(['\u2014' for i in 1:50]))
   for (key,item) in result
      @printf "%-30s | %-10s | %-10s\n" key[16:end] prettydiff(item.ratio.time) prettydiff(item.ratio.memory)
   end
   println()
   nothing
end

###
# GRAPH GENERATION
###
function bench_generation(V::Int, E::Int, tune_file = "generation_params.jld"; save_file = "", compare_file = "")
   suite = BenchmarkGroup(["Generation"])

   for AM in subtypes(AdjacencyModule)
      suite["$AM"] = @benchmarkable $AM($V, $E)
   end

   for PM in subtypes(PropertyModule)
      for typ in [Any,TestType]
         propmod = PM{typ,typ}
         suite["$PM"] = @benchmarkable $propmod($V)
      end
   end

   tune_suite(suite, tune_file)
   result = median(run(suite, seconds = 5))
   display(result)
   save_suite(result, save_file)
   compare_suite(result, compare_file)
   nothing
end
println("bench_generation(V::Int, E::Int, tune_file = \"generation_params.jld\"; save_file = \"\", compare_file = \"\")")


###
# SETVPROP
###

function bench_setvprop(V::Int, E::Int, tune_file = "setvprop_params.jld"; save_file = "", compare_file= "")
   suite = BenchmarkGroup(["Setvprop"])

   suite["Unit Single"] = BenchmarkGroup()
   suite["Unit Dict  "] = BenchmarkGroup()

   suite["Range Single"] = BenchmarkGroup()
   suite["Range Dict  "] = BenchmarkGroup()
   suite["Range Func  "] = BenchmarkGroup()

   suite["Array Single"] = BenchmarkGroup()
   suite["Array Dict  "] = BenchmarkGroup()
   suite["Array Func  "] = BenchmarkGroup()

   suite["Colon Single"] = BenchmarkGroup()
   suite["Colon Dict  "] = BenchmarkGroup()
   suite["Colon Func  "] = BenchmarkGroup()

   val=randstring()
   d = Dict("f1"=>1, "f2"=>2.0, "f3"=>randstring(), "f4"=>nothing, "f5"=>'5')

   range = div(V, 4) : div(V, 2)
   vlist = rand(1:V, div(V, 4))

   fn = v->rand([1, "1", 1.0, nothing])

   for PM in subtypes(PropertyModule)
      for typ in [Any,TestType]
         propmod = PM{typ,typ}
         suite["Unit Single"]["$propmod"] = @benchmarkable setvprop!(x, v, $val, "f3")          setup=(x=$propmod($V); v=rand(1:$V))
         suite["Unit Dict  "]["$propmod"] = @benchmarkable setvprop!(x, v, $d)                  setup=(x=$propmod($V); v=rand(1:$V))

         arr=Array{Int}(length(range))
         dlist = fill(d, length(range))
         suite["Range Single"]["$propmod"] = @benchmarkable setvprop!(x, $range, $arr, "f1")    setup=(x=$propmod($V))
         suite["Range Dict  "]["$propmod"] = @benchmarkable setvprop!(x, $range, $dlist)        setup=(x=$propmod($V))
         suite["Range Func  "]["$propmod"] = @benchmarkable setvprop!(x, $range, $fn, "f4")     setup=(x=$propmod($V))

         arr=Array{Int}(length(vlist))
         dlist = fill(d, length(vlist))
         suite["Array Single"]["$propmod"] = @benchmarkable setvprop!(x, $vlist, $arr, "f1")    setup=(x=$propmod($V))
         suite["Array Dict  "]["$propmod"] = @benchmarkable setvprop!(x, $vlist, $dlist)        setup=(x=$propmod($V))
         suite["Array Func  "]["$propmod"] = @benchmarkable setvprop!(x, $vlist, $fn, "f4")     setup=(x=$propmod($V))

         arr=Array{Int}(V)
         dlist = fill(d, V)
         suite["Colon Single"]["$propmod"] = @benchmarkable setvprop!(x, :, $arr, "f1")    setup=(x=$propmod($V))
         suite["Colon Dict  "]["$propmod"] = @benchmarkable setvprop!(x, 1:$V, $dlist)        setup=(x=$propmod($V))
         suite["Colon Func  "]["$propmod"] = @benchmarkable setvprop!(x, :, $fn, "f4")     setup=(x=$propmod($V))
      end
   end

   tune_suite(suite, tune_file)
   result = median(run(suite, seconds = 5))
   for key in sort(collect(keys(result)))
      println(key)
      display(result[key])
   end
   save_suite(result, save_file)
   compare_suite(result, compare_file)
   nothing
end
println("bench_setvprop(V::Int, E::Int, tune_file = \"setprop_params.jld\"; save_file = \"\", compare_file= \"\")")


###
# GETVPROP
###

function bench_getvprop(V::Int, E::Int, tune_file = "getvprop_params.jld"; save_file = "", compare_file= "")
   suite = BenchmarkGroup(["Getvprop"])

   suite["Unit Single"] = BenchmarkGroup()
   suite["Unit Dict  "] = BenchmarkGroup()

   suite["Range Single"] = BenchmarkGroup()
   suite["Range Dict  "] = BenchmarkGroup()

   suite["Array Single"] = BenchmarkGroup()
   suite["Array Dict  "] = BenchmarkGroup()

   suite["Colon Single"] = BenchmarkGroup()
   suite["Colon Dict  "] = BenchmarkGroup()

   val=randstring()
   d = Dict("f1"=>1, "f2"=>2.0, "f3"=>randstring(), "f4"=>nothing, "f5"=>'5')

   range = div(V, 4) : div(V, 2)
   vlist = rand(1:V, div(V, 4))
   
   props = ["f1", "f2", "f3", "f4", "f5"]

   for PM in subtypes(PropertyModule)
      for typ in [Any,TestType]
         propmod = PM{typ,typ}

         g = Graph{SparseMatrixAM,propmod}(V, E)

         setvprop!(g, :, v->rand(Int), "f1")
         setvprop!(g, :, v->rand(), "f2")
         setvprop!(g, :, v->randstring(), "f3")
         setvprop!(g, :, v->rand(3), "f4")
         setvprop!(g, :, v->rand(Char), "f5")


         suite["Unit Single"]["$propmod"] = @benchmarkable getvprop($g, v, prop)                setup=(v=rand(1:$V); prop=rand($props))
         suite["Unit Dict  "]["$propmod"] = @benchmarkable getvprop($g, v)                      setup=(v=rand(1:$V))

         suite["Range Single"]["$propmod"] = @benchmarkable getvprop($g, $range, prop)          setup=(prop=rand($props))
         suite["Range Dict  "]["$propmod"] = @benchmarkable getvprop($g, $range)

         suite["Array Single"]["$propmod"] = @benchmarkable getvprop($g, $vlist, prop)          setup=(prop=rand($props))
         suite["Array Dict  "]["$propmod"] = @benchmarkable getvprop($g, $vlist)

         suite["Colon Single"]["$propmod"] = @benchmarkable getvprop($g, :, prop)               setup=(prop=rand($props))
         suite["Colon Dict  "]["$propmod"] = @benchmarkable getvprop($g, :) 
      end
   end

   tune_suite(suite, tune_file)
   result = median(run(suite, seconds = 5))
   for key in sort(collect(keys(result)))
      println(key)
      display(result[key])
   end
   save_suite(result, save_file)
   compare_suite(result, compare_file)
   nothing
end
println("bench_getvprop(V::Int, E::Int, tune_file = \"getvprop_params.jld\"; save_file = \"\", compare_file= \"\")")



###
# SETEPROP
###

function bench_seteprop(V::Int, E::Int, tune_file = "seteprop_params.jld"; save_file = "", compare_file= "")
   suite = BenchmarkGroup(["Seteprop"])

   suite["Unit Single"] = BenchmarkGroup()
   suite["Unit Dict  "] = BenchmarkGroup()

   suite["Array Single"] = BenchmarkGroup()
   suite["Array Dict  "] = BenchmarkGroup()
   suite["Array Func  "] = BenchmarkGroup()

   suite["Colon Single"] = BenchmarkGroup()
   suite["Colon Dict  "] = BenchmarkGroup()
   suite["Colon Func  "] = BenchmarkGroup()

   val=randstring()
   d = Dict("f1"=>1, "f2"=>2.0, "f3"=>randstring(), "f4"=>nothing, "f5"=>'5')

   am = SparseMatrixAM(V, E)
   es = collect(edges(am))
   elist = rand(es, div(E, 4))
   fn = (u,v)->rand([1, "1", 1.0, nothing])

   for PM in subtypes(PropertyModule)
      for typ in [Any,TestType]
         propmod = PM{typ,typ}

         suite["Unit Single"]["$propmod"] = @benchmarkable seteprop!(x, e, $val, "f3")          setup=(x=$propmod($V); e=rand($es))
         suite["Unit Dict  "]["$propmod"] = @benchmarkable seteprop!(x, e, $d)                  setup=(x=$propmod($V); e=rand($es))

         arr=Array{Int}(length(elist))
         dlist = fill(d, length(elist))
         suite["Array Single"]["$propmod"] = @benchmarkable seteprop!(x, $elist, $arr, "f1")    setup=(x=$propmod($V))
         suite["Array Dict  "]["$propmod"] = @benchmarkable seteprop!(x, $elist, $dlist)        setup=(x=$propmod($V))
         suite["Array Func  "]["$propmod"] = @benchmarkable seteprop!(x, $elist, $fn, "f4")     setup=(x=$propmod($V))

         arr=Array{Int}(E)
         dlist = fill(d, E)
         suite["Colon Single"]["$propmod"] = @benchmarkable seteprop!(x, :, $es, $arr, "f1")    setup=(x=$propmod($V))
         suite["Colon Dict  "]["$propmod"] = @benchmarkable seteprop!(x, $es, $dlist)           setup=(x=$propmod($V))
         suite["Colon Func  "]["$propmod"] = @benchmarkable seteprop!(x, :, $es, $fn, "f4")     setup=(x=$propmod($V))
      end
   end

   tune_suite(suite, tune_file)
   result = median(run(suite, seconds = 5))
   for key in sort(collect(keys(result)))
      println(key)
      display(result[key])
   end
   save_suite(result, save_file)
   compare_suite(result, compare_file)
   nothing
end
println("bench_seteprop(V::Int, E::Int, tune_file = \"seteprop_params.jld\"; save_file = \"\", compare_file= \"\")")



###
# GETEPROP
###

function bench_geteprop(V::Int, E::Int, tune_file = "geteprop_params.jld"; save_file = "", compare_file= "")
   suite = BenchmarkGroup(["Getvprop"])

   suite["Unit Single"] = BenchmarkGroup()
   suite["Unit Dict  "] = BenchmarkGroup()

   suite["Array Single"] = BenchmarkGroup()
   suite["Array Dict  "] = BenchmarkGroup()

   suite["Colon Single"] = BenchmarkGroup()
   suite["Colon Dict  "] = BenchmarkGroup()

   am = SparseMatrixAM(V, E)
   es = collect(edges(am))
   elist = rand(es, div(E, 4))
   
   props = ["f1", "f2", "f3", "f4", "f5"]

   for PM in subtypes(PropertyModule)
      for typ in [Any,TestType]
         propmod = PM{typ,typ}

         x = propmod(V)

         seteprop!(x, :, es, (u,v)->rand(Int), "f1")
         seteprop!(x, :, es, (u,v)->rand(), "f2")
         seteprop!(x, :, es, (u,v)->randstring(), "f3")
         seteprop!(x, :, es, (u,v)->rand(3), "f4")
         seteprop!(x, :, es, (u,v)->rand(Char), "f5")


         suite["Unit Single"]["$propmod"] = @benchmarkable geteprop($x, e, prop)                setup=(e=rand($es); prop=rand($props))
         suite["Unit Dict  "]["$propmod"] = @benchmarkable geteprop($x, e)                      setup=(e=rand($es))

         suite["Array Single"]["$propmod"] = @benchmarkable geteprop($x, $elist, prop)          setup=(prop=rand($props))
         suite["Array Dict  "]["$propmod"] = @benchmarkable geteprop($x, $elist)

         suite["Colon Single"]["$propmod"] = @benchmarkable geteprop($x, $es, prop)               setup=(prop=rand($props))
         suite["Colon Dict  "]["$propmod"] = @benchmarkable geteprop($x, $es) 
      end
   end

   tune_suite(suite, tune_file)
   result = median(run(suite, seconds = 5))
   for key in sort(collect(keys(result)))
      println(key)
      display(result[key])
   end
   save_suite(result, save_file)
   compare_suite(result, compare_file)
   nothing
end
println("bench_geteprop(V::Int, E::Int, tune_file = \"geteprop_params.jld\"; save_file = \"\", compare_file= \"\")")