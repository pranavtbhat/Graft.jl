# ParallelGraphs

[![Build Status](https://travis-ci.org/pranavtbhat/ParallelGraphs.jl.svg?branch=master)](https://travis-ci.org/pranavtbhat/ParallelGraphs.jl)
[![codecov.io](http://codecov.io/github/pranavtbhat/ParallelGraphs.jl/coverage.svg?branch=master)](http://codecov.io/github/pranavtbhat/ParallelGraphs.jl)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/pranavtbhat/ParallelGraphs.jl/master/LICENSE.md)

ParallelGraphs hopes to be a general purpose graph processing framework. Some of the use cases addressed are:
- Storing and querying vertex or edge properties. ParallelGraphs allows the assignment of key-value pairs to vertices and edges, which can be used in various graph algorithms.
- Vertex Labelling. ParallelGraphs allows users to refer to vertices using arbitrary Julia types.
- Graph DB queries(WIP). ParallelGraphs will support SQL-like queries for graphs, such as filtering on vertex and edge properties.
- Massive Graph Analysis(WIP). ParallelGraphs will leverage [Dagger.jl](https://github.com/JuliaParallel/Dagger.jl) to allow for the parallel processing of very large graphs.

Every Graph type in ParallelGraphs is built with three separate modular components:
- An `AdjacencyModule` that stores all structural information in the graph. All structural queries are redirected to the `AdjacencyModule` in the graph.
- A `PropertyModule` that stores the property information in the graph. This component will serve as a Graph-DB and will handle all property related queries and operations.
- An `LabelModule`. Since vertices are referred to internally by integer indices, this module will translate arbitrary julia objects (as required by the user) into the integer indices required by internal implementations. Label support will be provided only for user queries (to improve performance).


## Adjacency Module
The Adjacency Module will be responsible for maintaining the structure of the graph. Methods implemented on the Adjacency Module will allow the user to mutate the graph, query adjacency information and perform graph algorithms.

ParallelGraphs has the following `AdjacencyModule`s implemented:
- `LightGraphsAM` : This module contains a `DiGraph` from *[LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl)* and therefore will support most of the graph algorithms from *LightGraphs*.
- `SparseMatrixAM` : This module maintains a matrix in the Compressed Sparse Column format (`SparseMatrixCSC`), and is expected to be more compact than `LightGraphsAM`. However, this module will not support as many algorithms.

## PropertyModule
The `PropertyModule` will be responsible for maintaining vertex and edge metadata. A Property Module is parameterized by two templates:

- `V` : The vertex descriptor.
- `E` : The edge descriptor.

If you know the field names and their types beforehand, you can pass them in as a User defined type and get better performance. However, if you cannot anticipate the number or types of the fields, pass in type `Any` to use a ditctionary instead.

ParallelGraphs provides two separate implementations:
- `LinearPM` : Based on the Array of Structures paradigm.
- `VectorPM` : Based on the Structure of Arrays paragigm.

## Graph Types
ParallelGraphs allows users to mix and match Adjacency and Property modules to create graph structures that suit their needs. A graph can be created using the parametric constructor.

```julia

# Create smaller graphs
g = Graph{LightGraphsAM,LinearPM}()                   # Create an empty graph
g = Graph{LightGraphsAM,LinearPM}(100)                # Create a graph with 100 vertices

# Create Large Sparse Graphs
g = Graph{SparseMatrixAM,Vector}(10^6, 10^8) # Create a graph with 1M vertices and 100M edges.
```

For less picky users, ParallelGraphs provides two typealiases:
- `SimpleGraph` : Graph type that supports LightGraphs.jl algorithms, and is suited to smaller graphs.
- `SparseGraph` : Graph type that use sparse datastructures, and is targetted at larger graphs.

## Queries
Most adjacency/property operations will be supported through indexing. Additionally, SQL like queries such as filter are also provided.

```julia
using ParallelGraphs

# Randomly generate a graph with 50 vertices and 500 edges.
srand(101)
g = SimpleGraph(50, 500)
# Graph{ParallelGraphs.LightGraphsAM,ParallelGraphs.PureDictPM{ASCIIString,Any}} with 50 vertices and 500 edges

# Generate properties and attach them to vertices.
setvprop!(g, :, v -> Faker.first_name(), "Name")
setvprop!(g, :, v -> rand(1:80), "Age")
setvprop!(g, :, v -> Faker.date(), "DoB")

# Generate properties and attach them to edges.
seteprop!(g, :, (u,v)->rand(1:10), "Weight")
seteprop!(g, :, (u,v)->Faker.color_name(), "Color")

# Instruct ParallelGraphs to use every Vertex's name property as its label
setlabel!(g, "Name")

# Vertex and Edge descriptors for the graph
V,E = g

# Display a view of all vertices in the graph
println(V)
# Vertex Descriptor, with  50 Vertices and 3 Properties
#
# ┌────────────────────┬────────────────────┬────────────────────┬────────────────────┐
# │Vertex Label        │Age                 │DoB                 │Name                │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │Reina               │23                  │2015-3-7            │Reina               │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │Andrés              │30                  │1976-12-8           │Andrés              │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │Mónica              │53                  │2002-9-13           │Mónica              │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │Aldonza             │11                  │2005-4-18           │Aldonza             │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │Norma               │77                  │2020-4-12           │Norma               │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │                    │                    │                    │                    │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │Pedro               │23                  │1988-1-7            │Pedro               │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │Liliana             │50                  │1975-1-22           │Liliana             │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │Armando             │32                  │2005-9-6            │Armando             │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │Elvia               │4                   │1976-9-1            │Elvia               │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │Alicia              │27                  │1978-2-28           │Alicia              │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │Socorro             │8                   │2007-2-19           │Socorro             │
# └────────────────────┴────────────────────┴────────────────────┴────────────────────┘

# Display a view of all edges in the graph
println(E)
# Edge Descriptor with 500 edges and 2 properties
#
# ┌────────────────────┬────────────────────┬────────────────────┐
# │Edge Label          │Color               │Weight              │
# ├────────────────────┼────────────────────┼────────────────────┤
# │Reina,Norma         │LightGoldenRodY...  │4                   │
# ├────────────────────┼────────────────────┼────────────────────┤
# │Reina,Ana           │DarkSalmon          │1                   │
# ├────────────────────┼────────────────────┼────────────────────┤
# │Reina,Helena        │FireBrick           │10                  │
# ├────────────────────┼────────────────────┼────────────────────┤
# │Reina,Minerva       │Moccasin            │3                   │
# ├────────────────────┼────────────────────┼────────────────────┤
# │Reina,Sergio        │LawnGreen           │2                   │
# ├────────────────────┼────────────────────┼────────────────────┤
# │                    │                    │                    │
# ├────────────────────┼────────────────────┼────────────────────┤
# │Socorro,Gerónim     │PaleGreen           │6                   │
# ├────────────────────┼────────────────────┼────────────────────┤
# │Socorro,María d     │MediumVioletRed     │2                   │
# ├────────────────────┼────────────────────┼────────────────────┤
# │Socorro,Octavio     │Wheat               │4                   │
# ├────────────────────┼────────────────────┼────────────────────┤
# │Socorro,Wendolin    │LawnGreen           │3                   │
# ├────────────────────┼────────────────────┼────────────────────┤
# │Socorro,Manuel      │MistyRose           │7                   │
# ├────────────────────┼────────────────────┼────────────────────┤
# │Socorro,Armando     │DarkGoldenRod       │4                   │
# └────────────────────┴────────────────────┴────────────────────┘

# Fetch all the properties assigned to vertex Silvano
V["Silvano"]
Vertex Descriptor, with  1 Vertices and 3 Properties

# ┌────────────────────┬────────────────────┬────────────────────┬────────────────────┐
# │Vertex Label        │Age                 │DoB                 │Name                │
# ├────────────────────┼────────────────────┼────────────────────┼────────────────────┤
# │Silvano             │31                  │2007-11-16          │Silvano             │
# └────────────────────┴────────────────────┴────────────────────┴────────────────────┘

# Fetch all the properties assigned to association "Cynthia" => "Alfonso"
g["Sara" => "Carolina"]
# Edge Descriptor with 1 edges and 2 properties
#
# ┌────────────────────┬────────────────────┬────────────────────┐
# │Edge Label          │Color               │Weight              │
# ├────────────────────┼────────────────────┼────────────────────┤
# │Sara,Carolina       │DarkMagenta         │2                   │
# └────────────────────┴────────────────────┴────────────────────┘

# Fetch associations from Silvano
g["Silvano"]'
# 1x8 Array{AbstractString,2}:
 # "Alejandro"  "Trinidad"  "Verónica"  "Minerva"  "Liliana"  "María Eugenia"  "Manuel"  "Alicia"

# Get a subgraph with vertices of age less than 65
vs = filter(V, "v.Age < 65")

# Get a subgraph with edges of weight less than 7
es = filter(g, "e.Weight < 7")

# Get a subgraph with vertices of age less than 65 and edges of weight less than 7
Graph(vs, es)
# Graph{ParallelGraphs.LightGraphsAM,ParallelGraphs.VectorPM{Any,Any}} with 40 vertices and 188 edges

```

## Acknowledgements
This project is supported by `Google Summer of Code` and mentored by [Viral Shah](https://github.com/ViralBShah) and [Shashi Gowda](https://github.com/shashi).
