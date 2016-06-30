# ParallelGraphs

[![Build Status](https://travis-ci.org/pranavtbhat/ParallelGraphs.jl.svg?branch=master)](https://travis-ci.org/pranavtbhat/ParallelGraphs.jl)
[![codecov.io](http://codecov.io/github/pranavtbhat/ParallelGraphs.jl/coverage.svg?branch=master)](http://codecov.io/github/pranavtbhat/ParallelGraphs.jl)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/pranavtbhat/ParallelGraphs.jl/master/LICENSE.md)

*Presentation available [here](https://pranavtbhat.github.io/ParallelGraphs.jl/#/)*

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
g = Graph{LightGraphsAM,VectorPM}()                   # Create an empty graph
g = Graph{LightGraphsAM,VectorPM}(100)                # Create a graph with 100 vertices

# Create Large Sparse Graphs
g = Graph{SparseMatrixAM,LinearPM}(1000000, 10000000) # Create a graph with 1M vertices and 10M edges.
```

For less picky users, ParallelGraphs provides two typealiases:
- `SimpleGraph` : Graph type that supports LightGraphs.jl algorithms, and is suited to smaller graphs.
- `SparseGraph` : Graph type that use sparse datastructures, and is targetted at larger graphs.

## Queries
Most adjacency/property operations will be supported through indexing. Additionally, SQL like queries such as filter are also provided. 

```julia
using ParallelGraphs

# Randomly generate a graph with 50 vertices and 500 edges.
g = SimpleGraph(50, 500)
# Graph{ParallelGraphs.LightGraphsAM,ParallelGraphs.PureDictPM{ASCIIString,Any}} with 50 vertices and 500 edges

# Generate properties and attach them to vertices.
setvprop!(g, "name", v -> Faker.first_name())
setvprop!(g, "age", v -> rand(1:80))
setvprop!(g, "DOB", v -> Faker.date())

# Generate properties and attach them to edges.
seteprop!(g, "weight", (u,v)->rand(1:10))
seteprop!(g, "color", (u,v)->Faker.color_name())

# Instruct ParallelGraphs to use every Vertex's name property as its label
setlabel!(g, "name")

# Fetch all the properties assigned to vertex Cynthia
g["Cynthia"]
# Dict{ASCIIString,Any} with 3 entries:
#   "name" => "Cynthia"
#   "age"  => 70
#   "DOB"  => "1976-8-2"

# Fetch all the properties assigned to association "Cynthia" => "Alfonso"
g["Cynthia" => "Alfonso"]
# Dict{ASCIIString,Any} with 2 entries:
#   "weight" => 8
#   "color"  => "LemonChiffon"

# Fetch associations from Cynthia
g["Cynthia", :]'
# 1x11 Array{AbstractString,2}:
#  "Zacarías"  "Alfonso"  "Patricio"  …  "Isabel"  "Indira"  "Zeferino"

# Fetch associations to Cynthia
g[:, "Cynthia"]'
# 1x13 Array{AbstractString,2}:
#  "Cristobal"  "Patricia"  "Abigail"  …  "Araceli"  "Isabel"  "Natalia"

# Get a subgraph with vertices of age less than 65
filter(g, "v.age < 65")
# Graph{ParallelGraphs.LightGraphsAM,ParallelGraphs.PureDictPM{K,V}} with 45 vertices and 402 edges

# Get a subgraph with edges of weight less than 7
filter(g, "e.weight < 7")
# Graph{ParallelGraphs.LightGraphsAM,ParallelGraphs.PureDictPM{K,V}} with 50 vertices and 305 edges

```

## Acknowledgements
This project is supported by `Google Summer of Code` and mentored by [Viral Shah](https://github.com/ViralBShah) and [Shashi Gowda](https://github.com/shashi).
