# ParallelGraphs
ParallelGraphs hopes to be a general purpose graph processing framework. The package will be built on the following abstractions:
- Only directed graphs are supported.
- Vertices are referred to by an integer indices only. (Label support?)
- Properties (key-value pairs) can be assigned to vertices and edges. (Multigraph support through edge properties?)
- Small graphs will be operated on locally, using sequential algorithms from LightGraphs.
- Large graphs will be dealt with using ComputeFramework. 

## Graph Interface
Every type that implements the `Graph` interface is expected to define the following methods:
- `nv` : Return the number of vertices in the graph.
- `ne` : Return the number of edges in the graph.
- `adj` :  Return the neighbors of a vertex. (Change this to `fadj` and `rad`j?)
- `getprop` : Fetch properties from a vertex/edge.
- `setprop!` : Modify the properties assigned to a vertex/edge.
-  `addvertex` : Add a vertex to the graph. 
- `addedge` : Add an edge to the graph.

## Graph Types
ParallelGraphs will support a variety of graph types, and will provide conversions between these types.

### SparseGraph
Graphs of this type will use N-Dimensional sparse arrays to store graph property and structural information. This type is 
mainly aimed at achieving parallelized computation. SparseGraph will have two separate implementations:
- `LocalSparseGraph` : In-memory type for small graphs.
- `DistSparseGraph`  : Distributed type (using ComputeFramework) for larger graphs.

The `DistSparseGraph` variant will consist of several `LocalSparseGraph` objects, placed on different processes.

### LGSparseGraph
Graphs of this type will consist of a `LightGraphs.Graph` object for structural information, and an N-Dimensional sparse
array for property information. This type is mainly aimed at achieving fast sequential computation on small graphs.
This type will support most of the algorithms from `LightGraphs.jl`. 

### LabelGraphs(?)
Graphs of this type will allow indexing on vertex labels. This type will use dictionaries to store structure and property information.

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

I also hope to implement a descriptive query language which will help data scientists quickly mine information from the graph, through the REPL.
Things I have in mind are:

```julia
@pg ?.age = 5           # Return all vertices with the age property set to 5

@pg 1.?.relationship = follow # Return all vertices followed by vertex 1.

@pg usegraph(g)         # Tell the system which graph you're using.

@pg 1 -> ?              # Get vertex 1's out-neighbors

@pg ? -> 1              # Get vertex 1s in-neighbors

@pg 1 -(3)> ?           # Get all vertices at a distance of 3 from vertex 1.

@pg 1 -(?)> 2           # Get the distance between vertex 1 and 2
```