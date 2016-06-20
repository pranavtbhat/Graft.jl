using ParallelGraphs
using JLD
using BenchmarkTools

import BenchmarkTools: prettytime, prettymemory, prettydiff

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
   @printf "%-20s | %-10s | %-10s | %-10s\n" "Test" "Time Taken" "Memory" "GCTime"
   println(join(['\u2014' for i in 1:57]))
   for (key,item) in result
      @printf "%-20s | %-10s | %-10s | %-10s\n" key[16:end] prettytime(item.time) prettymemory(item.memory) prettytime(item.gctime)
   end
   println()
   nothing
end

function display_compare(result)
   @printf "%-20s | %-10s | %-10s\n" "Test" "Time Taken" "Memory"
   println(join(['\u2014' for i in 1:45]))
   for (key,item) in result
      @printf "%-20s | %-10s | %-10s\n" key[16:end] prettydiff(item.ratio.time) prettydiff(item.ratio.memory)
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
# 
###

function bench_setprop(V::Int, E::Int, tune_file = "setprop_params.jld"; save_file = "", compare_file= "")
   suite = BenchmarkGroup(["Setprop"])

   suite["unit"] = BenchmarkGroup()
   for PM in subtypes(PropertyModule)
      val=randstring()
      suite["unit"]["$PM"] = @benchmarkable setvprop!(g, v, "test1", $val) setup=(g=Graph{SparseMatrixAM,$PM}($V,$E); v=rand(1:$V))
   end

   suite["dict"] = BenchmarkGroup()
   for PM in subtypes(PropertyModule)
      d = Dict("test1"=>1, "test2"=>"txt", "test3"=>3.0, "test4"=>nothing)
      suite["dict"]["$PM"] = @benchmarkable setvprop!(g, v, $d) setup=(g=Graph{SparseMatrixAM,$PM}($V,$E); v=rand(1:$V))
   end

   suite["array"] = BenchmarkGroup()
   for PM in subtypes(PropertyModule)
      suite["array"]["$PM"] = @benchmarkable setvprop!(g, "test1", arr) setup=(g=Graph{SparseMatrixAM,$PM}($V,$E); v=rand(1:$V); arr=Array{Int}($V))
   end

   tune_suite(suite, tune_file)
   result = median(run(suite, seconds = 10))
   for (key,val) in result
      println(key)
      display(val)
   end
   save_suite(result, save_file)
   compare_suite(result, compare_file)
   nothing
end
   

