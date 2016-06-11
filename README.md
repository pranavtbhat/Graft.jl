# ParallelGraphs
ParallelGraphs hopes to be a general purpose graph processing framework. The package will be built on the following abstractions:
- Only directed graphs are supported.
- Vertices are internally referred to by integer indices. Label Support (with arbitrary julia types) will be provided for queries only.
- Properties (key-value pairs) can be assigned to vertices and edges. 
- Small graphs will be operated on locally, using fast sequential algorithms.
- Large graphs will be dealt with using ComputeFramework. 

Every Graph type is built with three separate modular components:
- An `AdjacencyModule` that stores all structural information in the graph. All structural queries are redirected to the `AdjacencyModule` in the graph.
- A `PropertyModule` that stores the property information in the graph. This component will serve as a Graph-DB and will handle all property related queries and operations.
- An optional `LabelModule`. Since vertices are referred to by integer indices, this module will translate arbitrary julia objects (as required by the user) into the integer indices required by internal implementations. Label support will be provided only for user queries (to improve performance).


## Adjacency Module
The Adjacency Module will be responsible for maintaining the structure of the graph. Methods implemented on the Adjacency Module will allow the user to mutate the graph, query adjacency information and perform graph algorithms.

ParallelGraphs has the following `AdjacencyModule`s implemented:
- `LightGraphsAM` : This module contains a `DiGraph` from *[LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl)* and therefore will support most of the graph algorithms from *LightGraphs*.
- `SparseMatrixAM` : This module maintains a matrix in the Compressed Sparse Column format (`SparseMatrixCSC`), and is expected to be more compact than `LightGraphsAM`. However, this module will not support as many algorithms.

## PropertyModule
The `PropertyModule` will be responsible for maintaining information attached to vertices and edges. Methods implemented on the Property Module will allow the user to fetch vertex/edge data and execute SQL like queries. 

ParallelGraphs has the following `PropertyModule`s implemented:
- `DictPM` : Uses the standard Julia `Dictionary` type to store vertex/edge properties.
- `NDSparsePM` : Uses N-Dimensional Sparse arrays from *[NDSparseData.jl](https://github.com/JuliaComputing/NDSparseData.jl)* to store vertex/edge properties.


## Graph Types
ParallelGraphs allows users to mix and match Adjacency and Property modules to create graph structures that suit their needs. A graph can be created using the parametric constructor.

```julia
g = Graph{SparseMatrixAM,NDSparsePM{ASCIIString,Any}}()          # Create an empty graph
g = Graph{SparseMatrixAM,NDSparsePM{ASCIIString,Any}}(100)       # Create a graph with 100 vertices
g = Graph{SparseMatrixAM,NDSparsePM{ASCIIString,Any}}(100, 500)  # Create a graph with 500 edges.
```

For less picky users:
```julia
g = SimpleGraph(100, 500)  # Create a graph with LightGraphsAM and DictPM{ASCIIString,Any}

fadj(g, 1)                 # Fetch vertex 1's adjacencies

addvertex!(g)              # Add a vertex to g

addedge!(g, 7, 8)          # Add the edge 7 => 8 to g.
```

## Queries
Most adjacency/property operations will be supported through indexing. Additionally, SQL like queries such as filter are also provided. 

```julia
using ParallelGraphs

# Create a graph
g = SimpleGraph(50, 500);
# Graph{ParallelGraphs.LightGraphsAM,ParallelGraphs.DictPM{ASCIIString,Any}} with 50 vertices and 500 edges

# Attach randomly generated property to each vertex.
random_vertex_prop!(g, "name", () -> Faker.first_name())
random_vertex_prop!(g, "age", () -> rand(1:100))
random_vertex_prop!(g, "DOB", () -> Faker.date())

# Attach a propety called "weight" to each edge in the graph.
random_edge_prop!(g, "weight", ()->rand(1:10))
random_edge_prop!(g, "color", ()->Faker.color_name())

# Fetch all the properties assigned to vertex 1
g[1]
# Dict{ASCIIString,Any} with 3 entries:
#  "name" => "Bernardo"
#  "age"  => 48
#  "DOB"  => "2013-8-10"

# Fetch vertex 1's name
g[1]["name"]
# "Bernardo"

# Fetch all the properties assigned to edge 1 => 2
g[1, 2]
# Dict{ASCIIString,Any} with 2 entries:
#  "weight" => 2
#  "color"  => "MediumTurquoise"

# Fetch the relationship type of edge 1 => 2
g[1, 2]["weight"]
# 2

# Fetch the forward adjacencies of a vertex
g[1, :]
# 1x13 Array{Int64,2}:
#  3  4  6  7  10  13  14  22  26  31  34  36  45

# Fetch the reverse adjacencies of a vertex
g[:, 1]
# 1x9 Array{Int64,2}:
#  12  16  17  20  24  27  29  32  42

# Get a subgraph with vertices of age less than 65
filter(g, "v.age < 65")
# Graph{ParallelGraphs.LightGraphsAM,ParallelGraphs.DictPM{ASCIIString,Any}} with 29 vertices and 173 edges
```

## Achnowledgements
This project is supported by `Google Summer of Code` and mentored by [Viral Shah](https://github.com/ViralBShah) and [Shashi Gowda](https://github.com/shashi).
