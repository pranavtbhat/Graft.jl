## Graph Generation

The `Graph` constructor can be used directly to generate random regular graphs:

```@repl
using Graft

# Generate a graph with 10 vertices and no edges.
Graph(10)

# Generate a graph with 10 vertices and (approximately) 50 edges
Graph(10, 50)

# Generate a labelled graph with 10 vertices
# labelled "1" through "10" and no edges
Graph(10, map(string, 1 : 10))

# Generate a labelled graph with 10 vertices
# and (approximately) 50 edges
Graph(10, map(string, 1 : 10), 50)

# Generate graph from an adjacency matrix (may cause self loops)
Graph(sprand(Int, 10, 10, .3))
```

`completegraph` can be used to generate a complete graph
```@repl
using Graft

# Generate a complete graph with 10 vertices
g = completegraph(10)
```

`randgraph` can be used to generate a complete graph, with floating point vertex and edge properties:

```@repl
using Graft

# Generate a graph with 10 vertices, 90 edges, 2 vertex properties and 2 edge properties
g = propgraph(10, [:p1,:p2], [:p1,:p2])
```


Detailed documentation:
```@docs
Graph(::Int)
Graph(::Int, ::Int)
Graph(::Int, ::Vector)
Graph(::Int, ::Vector, ::Int)
Graph(::SparseMatrixCSC)
completegraph
randgraph
propgraph
```
