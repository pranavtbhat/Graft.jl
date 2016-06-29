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
   @printf "%-30s | %-10s | %-10s | %-10s\n" "Test" "Time Taken" "Memory" "GCTime"
   println(join(['\u2014' for i in 1:57]))
   for (key,item) in result
      @printf "%-30s | %-10s | %-10s | %-10s\n" key[16:end] prettytime(item.time) prettymemory(item.memory) prettytime(item.gctime)
   end
   println()
   nothing
end

function display_compare(result)
   @printf "%-30s | %-10s | %-10s\n" "Test" "Time Taken" "Memory"
   println(join(['\u2014' for i in 1:45]))
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
      suite["$AM"] = @benchmarkable ($AM($V, $E))
   end

   for PM in subtypes(PropertyModule)
      suite["$PM"] = @benchmarkable ($PM($V))
   end

   tune_suite(suite, tune_file)
   result = median(run(suite, seconds = 10))
   display(result)
   save_suite(result, save_file)
   compare_suite(result, compare_file)
   nothing
end
println("bench_generation(V::Int, E::Int, tune_file = \"generation_params.jld\"; save_file = \"\", compare_file = \"\")")


###
# SETVPROP
###

function bench_setvprop(V::Int, E::Int, tune_file = "setprop_params.jld"; save_file = "", compare_file= "")
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

   for PM in subtypes(PropertyModule)
      for typ in [Any,TestType]
         suite["Unit Single"]["$(PM{typ,typ})"] = @benchmarkable setvprop!(g, v, "f3", $val) setup=(g=Graph{SparseMatrixAM,$PM}($V,$E); v=rand(1:$V))
         suite["Unit Dict  "]["$(PM{typ,typ})"] = @benchmarkable setvprop!(g, v, $d) setup=(g=Graph{SparseMatrixAM,$PM}($V,$E); v=rand(1:$V))

         arr=Array{Int}(length(range))
         dlist = fill(Dict("f1"=>1, "f2"=>2.0, "f3"=>randstring(), "f4"=>nothing, "f5"=>'5'), length(range))
         suite["Range Single"]["$(PM{typ,typ})"] = @benchmarkable setvprop!(g, $range, $arr, "f1") setup=(g=Graph{SparseMatrixAM,$PM}($V,$E))
         suite["Range Dict  "]["$(PM{typ,typ})"] = @benchmarkable setvprop!(g, $range, $dlist) setup=(g=Graph{SparseMatrixAM,$PM}($V,$E))
         suite["Range Func  "]["$(PM{typ,typ})"] = @benchmarkable setvprop!(g, $range, v->rand([1, "1", 1.0, nothing]), "f4") setup=(g=Graph{SparseMatrixAM,$PM}($V,$E))

         arr=Array{Int}(length(vlist))
         dlist = fill(Dict("f1"=>1, "f2"=>2.0, "f3"=>randstring(), "f4"=>nothing, "f5"=>'5'), length(vlist))
         suite["Array Single"]["$(PM{typ,typ})"] = @benchmarkable setvprop!(g, $vlist, $arr, "f1") setup=(g=Graph{SparseMatrixAM,$PM}($V,$E))
         suite["Array Dict  "]["$(PM{typ,typ})"] = @benchmarkable setvprop!(g, $vlist, $dlist) setup=(g=Graph{SparseMatrixAM,$PM}($V,$E))
         suite["Array Func  "]["$(PM{typ,typ})"] = @benchmarkable setvprop!(g, $vlist, v->rand([1, "1", 1.0, nothing]), "f4") setup=(g=Graph{SparseMatrixAM,$PM}($V,$E))

         arr=Array{Int}(V)
         dlist = fill(Dict("f1"=>1, "f2"=>2.0, "f3"=>randstring(), "f4"=>nothing, "f5"=>'5'), V)
         suite["Colon Single"]["$(PM{typ,typ})"] = @benchmarkable setvprop!(g, :, $arr, "f1") setup=(g=Graph{SparseMatrixAM,$PM}($V,$E))
         suite["Colon Dict  "]["$(PM{typ,typ})"] = @benchmarkable setvprop!(g, :, $dlist) setup=(g=Graph{SparseMatrixAM,$PM}($V,$E))
         suite["Colon Func  "]["$(PM{typ,typ})"] = @benchmarkable setvprop!(g, :, v->rand([1, "1", 1.0, nothing]), "f4") setup=(g=Graph{SparseMatrixAM,$PM}($V,$E))
      end
   end

   tune_suite(suite, tune_file)
   result = median(run(suite, seconds = 10))
   for key in sort(collect(keys(result)))
      println(key)
      display(result[key])
   end
   save_suite(result, save_file)
   compare_suite(result, compare_file)
   nothing
end
   

