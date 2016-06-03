# ParallelGraphs
ParallelGraphs hopes to be a general purpose graph processing framework. The package will be built on the following abstractions:
- Only directed graphs are supported.
- Vertices are internally referred to by integer indices. Label Support (with arbitrary julia types) will be provdided for queries only.
- Properties (key-value pairs) can be assigned to vertices and edges. 
- Small graphs will be operated on locally, using sequential algorithms.
- Large graphs will be dealt with using ComputeFramework. 

Every Graph type is built with three separate modular components:
- An `AdjacencyModule` that stores all structural information in the graph. All structural queries are redirected to the `AdjacencyModule` in the graph.
- A `PropertyModule` that stores the property information in the graph. This component will serve as a Graph-DB and will handle all property related queries and operations.
- An optional `LabelModule`. Since vertices are referred to by integer indices, this module will translate arbitrary julia objects (as requried by the user) into the integer indices required by internal implementations. Label support will be provided only for user queries (to improve performance).


## Adjacency Module
Every `AdjacencyModule` subtype is expected to implement the following interface:
- `nv` : Return the number of vertices in the graph.
- `ne` : Return the number of edges in the graph.
- `adj` :  Return the neighbors of a vertex. (Change this to `fadj` and `rad`j?)
-  `addvertex!` : Add a vertex to the graph. 
-  `rmvertex!` : Remove a vertex from the graph.
- `addedge!` : Add an edge to the graph.
- `rmedge!` : Remove an edge from the graph.

ParallelGraphs has the following `AdjacencyModule`s implemented:
- `LightGraphsAM` : This module contains a `DiGraph` from *[LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl)* and therefore will support all graph algorithms from *LightGraphs*.
- `SparseMatrixAM` : This module maintains a matrix in the Compressed Sparse Column format (`SparseMatrixCSC`), and is expected to be more compact than `LightGraphsAM`. However, this module will not support many algorithms.

## PropertyModule
Every `PropertyModule` subtype is expected to implement the following interface:
- `listvprops` : List all the vertex properties in the graph.
- `listeprops` : List all the edge properties in the graph. 
- `getvprop` : Fetch properties from a vertex.
- `geteprop` : Fetch properties from an edge.
- `setvprop!` : Modify the properties assigned to a vertex.
- `seteprop!` : Modify the properties assigned to an edge.

ParallelGraphs has the following `PropertyModule`s implemented:
- `DictPM` : Uses the standard Julia `Dictionary` type to store vertex/edge properties.
- `NDSparsePM` : Uses N-Dimensional Sparse arrays from *[NDSparseData.jl](https://github.com/JuliaComputing/NDSparseData.jl)* to store vertex/edge properties.


## Graph Types
ParallelGraphs currently implements the following Graph types:
- `SimpleGraph` : This graph type uses `LightGraphsAM` and `DictPM`, and will support only `ASCIIString` properties.
- `CustomGraph` : A parameterized, fully customizable graph.


## Queries
Most adjacency/property operations will be supported through indexing. For example, consider a graph where each vertex 
represents a person, with attributes `name` and `age`. Edges are used to model relationships, with there being two different types
of relationships: `follow` and `friend`.
```julia
g = parsegraph("graph.txt", :TGF)

# Fetch all the properties assigned to vertex 1
g[1]

# Fetch vertex 1's name
g[1]["name"]

# Fetch vertex 1's age
g[1]["age"]

# Fetch all the properties assigned to edge 1 => 2
g[1, 2]

# Fetch the relationship type of edge 1 => 2
g[1, 2]["relationship"]

# Fetch the adjacencies of a vertex
g[1, :]
```

## Achnowledgements
This project is supported by `Google Summer of Code` and mentored by [Viral Shah](https://github.com/ViralBShah) and [Shashi Gowda](https://github.com/shashi).
