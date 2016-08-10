# Graft

[![Build Status](https://travis-ci.org/pranavtbhat/Graft.jl.svg?branch=master)](https://travis-ci.org/pranavtbhat/Graft.jl)
[![codecov.io](http://codecov.io/github/pranavtbhat/Graft.jl/coverage.svg?branch=master)](http://codecov.io/github/pranavtbhat/Graft.jl)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/pranavtbhat/Graft.jl/master/LICENSE.md)

Graft is a general purpose graph processing framework, and can be thought of as a *DataFrames.jl* for Graphs. Graft supports
vertex and edge metadata, vertex labelling and SQL-like queries.

Two separate views of a graph are presented:

## Graph Datastructure
Graft provides a generic graph interface that can have multiple implementations:
```julia
# Create a (10,90) directed graph with a LightGraphs backend. Use this interface if you want to
# apply sequential algorithms on smallish graphs
g = randgraph(SimpleGraph, 10^3, 10^5)

# Create a (10,90) directed graph with a SparseMatrixCSC backend. Use this if you want to work  
# with very large graphs.  
g = randgraph(SparseGraph, 10^6, 10^8)      

# If you really don't care about interfaces, skip the graph type argument
g = emptygraph(0)

# Add a vertex labelled v1
g + "v1";

# Add v1's friends
g + ["v2", "v3", "v4", "v5", "v6"];

# Draw edges between v1 and its friends
g["v1"] = ["v2"];
g["v2"] = ["v3", "v4", "v5", "v6"];

# Check out v1's new neighbors
g["v1"]
# ["v2"]

# Run a vfs starting from vertex v1
@bfs g "v1"
# ["v2", "v3", "v4", "v5", "v6"]
```

By default vertices have the internally assigned integer indices. Labels can be when adding new vertices,
or by calling the `setlabel!` method.

## Vertex and Edge Descriptors
Descriptors behave like table-views of graphs:

```julia
g = randgraph(10^4, 10^6)

# Label every vertex with "v$i"
setlabel!(g, ["v$i" for i in 1:10^4])

# Vertex and Edge Descriptors
V, E = g
```

Descriptors can be used to run a Julia statement on every vertex/edge.
```julia
# Attach randomly generated properties to each vertex
V |> @query v.p1 = rand()
V |> @query v.p2 = rand(1:100)
V |> @query v.p3 = randstring()

# Attach randomly generated properties to each edge (u,v)
E |> @query e.p1 = u.p1 + v.p1
E |> @query e.p2 = u.p2 * v.p2
E |> @query e.p3 = string(u.p3, v.p3)

# Table view of the Vertex Descriptor
V
# Vertex Descriptor, with  10000 Vertices and 3 Properties
# ┌────────────────────┬────────────────────┬────────────────────┬────────────────────┐
# │Vertex Label        │p1                  │p2                  │p3                  │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v1                  │0.0886765703681...  │84                  │8Oo7yCnn            │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v2                  │0.5447535485492...  │5                   │jeLoDfpJ            │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v3                  │0.7073385816035...  │25                  │CeKD51Cf            │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v4                  │0.4913099817997...  │3                   │ONMmhhZG            │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v5                  │0.5623334623679...  │14                  │uKvS5xu3            │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │                    │                    │                    │                    │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v9995               │0.5613852334899...  │97                  │knBYJQWf            │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v9996               │0.4898850457780...  │30                  │NbAT75gc            │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v9997               │0.3108808790190...  │87                  │IeKA5qLe            │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v9998               │0.9409665402523...  │20                  │IsFazqQ8            │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v9999               │0.9292089950377...  │64                  │Zzw1eada            │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v10000              │0.3583293715985...  │70                  │RrcMkYxW            │
# └────────────────────┴────────────────────┴────────────────────┴────────────────────┘

# Table view of the Edge Descriptor
E
# Edge Descriptor with 1001959 edges and 3 properties
# ┌────────────────────┬────────────────────┬────────────────────┬────────────────────┐
# │Edge Label          │p1                  │p2                  │p3                  │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v1,v114             │0.4570625414951...  │5628                │8Oo7yCnnLdyJMZC...  │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v1,v177             │0.8510643282339...  │6636                │8Oo7yCnn9s8raFg...  │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v1,v336             │0.2863039980798...  │5964                │8Oo7yCnni7wiA87...  │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v1,v478             │0.6739877221233...  │4536                │8Oo7yCnno3fa9bq...  │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v1,v729             │0.6719885669343...  │3780                │8Oo7yCnnQZNPcwq...  │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │                    │                    │                    │                    │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v10000,v9814        │1.1602328312601...  │70                  │RrcMkYxWnD37V9g...  │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v10000,v9816        │1.3545157779170...  │3570                │RrcMkYxWnbL68NL...  │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v10000,v9848        │0.6012915336647...  │4060                │RrcMkYxWLiG6NXq...  │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v10000,v9851        │0.8759764277288...  │2380                │RrcMkYxWmGkgmZY...  │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v10000,v9959        │0.9247948535083...  │2940                │RrcMkYxWLdmQi4C...  │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │v10000,v9974        │0.4030419119765...  │280                 │RrcMkYxWDeA1shF...  │
# └────────────────────┴────────────────────┴────────────────────┴────────────────────┘

# Compute a value on every vertex
V |> @query v.p1 + 2 * v.p2

# Find the largest value for field p1
V |> @query(v.p1) |> maximum
```

Descriptors can also be `filter`ed, and `select`ed to yield smaller Descriptors.

```julia
# Filter out all vertices with p1 > 0.5
V |> @filter v.p1 <= 0.5

# Chain filtering
V |> @filter(0.1 <= v.p1 <= 0.5) |> @filter(v.p2 < 50)

# Select only p1
select(V, "p1")
# Vertex Descriptor, with  10000 Vertices and 1 Properties
#
# ┌────────────────────┬────────────────────┐
# │Vertex Label        │p1                  │
# ├────────────────────┼────────────────────┤
# │v1                  │0.4359654138336...  │
# ├────────────────────┼────────────────────┤
# │v2                  │0.6531249345440...  │
# ├────────────────────┼────────────────────┤
# │v3                  │0.7285400192499...  │
# ├────────────────────┼────────────────────┤
# │v4                  │0.9706805845443...  │
# ├────────────────────┼────────────────────┤
# │v5                  │0.0658167326554...  │
# ├────────────────────┼────────────────────┤
# │                    │                    │
# ├────────────────────┼────────────────────┤
# │v9995               │0.3949059321178...  │
# ├────────────────────┼────────────────────┤
# │v9996               │0.1933076479556...  │
# ├────────────────────┼────────────────────┤
# │v9997               │0.0840808256994...  │
# ├────────────────────┼────────────────────┤
# │v9998               │0.6368603632994...  │
# ├────────────────────┼────────────────────┤
# │v9999               │0.8213442058510...  │
# ├────────────────────┼────────────────────┤
# │v10000              │0.7188503605295...  │
# └────────────────────┴────────────────────┘
```

## Acknowledgements
This project is supported by `Google Summer of Code` and mentored by [Viral Shah](https://github.com/ViralBShah) and [Shashi Gowda](https://github.com/shashi).
