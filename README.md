[![Build Status](https://travis-ci.org/pranavtbhat/ParallelGraphs.jl.svg?branch=master)](https://travis-ci.org/pranavtbhat/ParallelGraphs.jl)
*NOTE: Only Julia `0.4` is supported as of now.*

# ParallelGraphs
ParallelGraphs.jl is a framework for Massive-Graph Analysis built on [ComputeFramework.jl](https://github.com/shashi/ComputeFramework.jl). ParallelGraphs.jl implements the Bulk Synchronous Parallel Model for running graph algorithms. The framework is under development, and there's probably a long way to go before the first release.

The graph algorithms use very light data structures, motivated by [LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl). Interoperability with LightGraphs.jl is a development goal.

The framework uses the Main Julia process to schedule iterations and handle control messages. Computations take place on worker processes. Therfore *atleast* one worker process is required for the framework to function correctly.

## Requirements
- ComputeFramework.jl

## Algorithms currently supported
- Breadth First Search (supports multiple seeds)
- Connected Components (Undirected graphs only)

## Example Usage
```julia
addprocs(2)
using ParallelGraphs

# Breadth First Search
g = rand_graph(100000, 0.00003)
@time distvector, parentvector = bfs(g)

# Connected Components
g = rand_graph(100000, 0.00003)
@time distvector, parentvector = connected_components(g)
```
