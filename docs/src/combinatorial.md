### Combinatorial API

The following example demonstrates the use of the combinatorial API:
```@repl
using Graft

g = completegraph(10)
setlabel!(g, map(string, 1 : 10))

# The number of vertices in the graph
nv(g)

# The number of edges in the graph
ne(g)

# The internally used vertex identifiers
vertices(g)

# Get an iterator overt all edges in the graph
edges(g)

# Check if the input vertex identifier exists in the graph
hasvertex(g, 11)

# Check if the input edge exists in the graph
hasedge(g, 1=>1)

# Get a list containing the input vertex's out-neighbors
fadj(g, 1)

# Get the out-neighbors of a labelled vertex
g["1"]

# Get the input vertex's out-neighbors in a preallocated array
adj = sizehint!(Int[], nv(g));
fadj!(g, 1, adj)

# Count the number of out-neighbors the input vertex has
outdegree(g, 1)

# Count the number of in-neighbors the input vertex has
indegree(g, 1)
```

Detailed documentation:

```@docs
nv(::Graph)
ne(::Graph)
fadj(::Graph, ::Int)
fadj!(::Graph, ::Int, ::Vector{Int})
outdegree(::Graph, ::Int)
indegree(::Graph, ::Int)
```
