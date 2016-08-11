# Graft.jl

| Build|Coverage| License|
|------|--------|--------|
| [![Build Status](https://travis-ci.org/pranavtbhat/Graft.jl.svg?branch=master)](https://travis-ci.org/pranavtbhat/Graft.jl)| [![codecov.io](http://codecov.io/github/pranavtbhat/Graft.jl/coverage.svg?branch=master)](http://codecov.io/github/pranavtbhat/Graft.jl)| [![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/pranavtbhat/Graft.jl/master/LICENSE.md) |

A graph toolkit for Julia.

Graft stores vertex and edge metadata in separate dataframes. Adjacencies are stored in a sparsematrix, which also indexes into the edge dataframe. Vertex labels are supported for all external queries, using a bidirectional map. Vertex labels may be of any Julia type.

Data manipulation and analysis in Graft is accomplished with a pipelined query macro system adopted from Jplyr. User queries are parsed recursively, to build a DAG. The DAG is then executed from the bottom up. Results from the execution of intermediate nodes or table data-retrievals are cached to avoid redundant computations.

## Installation
Graft isn't registered yet, so you can clone it directly using:
```julia
julia> Pkg.clone("https://github.com/pranavtbhat/Graft.jl.git")
```

## Example
This example shows how Graft can be used for social network analysis:

```julia
using Graft


julia> # Construct a graph
       g = Graph(10^4, 10^6)
Graph(10000 vertices, 1000838 edges, Symbol[] vertex properties, Symbol[] edge properties)

julia> # Assign String labels to all vertices
       setlabel!(g, map(string, vertices(g)));

julia> # Assign an age, weight and height to each vertex
       setvprop!(g, :, rand(1:100, nv(g)), :age)
       setvprop!(g, :, rand(45:80, nv(g)), :weight)
       setvprop!(g, :, rand(140:))

julia> # Assign a follow/friend relationship to each edge
       seteprop!(g, :, rand(["follow", "friend"], ne(g)), :relationship)

julia> # Find the average age of vertex 1's friends
       nhood = hoptree(g, "1", 1);
       @query(nhood |> filter(e.relationship == "friend") |> eachedge(t.age)) |> mean
54.0

# Compute vertex 1's 2-hop neighborhood
nhood = hopgraph(g, "1", 2)
# Graph(7015 vertices, 496366 edges, Symbol[:age] vertex properties, Symbol[:relationship] edge properties)

# Find the average age in the neighborhood
@query(nhood |> eachvertex(v.age)) |> mean
# 49.70876692801141

# Find the average age in a follows relationship in the neighborhood
@query(nhood |> filter(e.relationship == "follow") |> eachedge(s.age + t.age)) |> mean
```

## Acknowledgements
This project is supported by `Google Summer of Code` and mentored by [Viral Shah](https://github.com/ViralBShah) and [Shashi Gowda](https://github.com/shashi).
