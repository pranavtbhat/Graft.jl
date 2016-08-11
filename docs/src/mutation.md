# Mutation API
The following example demonstrates the use of the combinatorial API:Graphs can be modified using the following methods:

```@repl
using Graft

g = completegraph(10)
setlabel!(g, map(string, 1 : 10))

# Add a labelled vertex to the graph. Returns the new
# vertex's internal identifier
addvertex!(g, "11")

# Add a new edge to the graph, using vertex identifiers
addedge!(g, 1=>11)

# Add a new edge to the graph, using vertex labels
g["2"] = "11"

# Remove an edge from the graph, using vertex identifiers
rmedge!(g, 1=>11)

# Remove a vertex from the graph, using its vertex identifier
rmvertex!(g, 1)

# Remove a vertex from the graph using its label
g - "5"

```

Detailed documentation:

```@docs
addvertex!(::Graph, ::Any)
addvertex!(::Graph, ::Any)
addedge!(::Graph, ::Pair{Int,Int})
rmvertex!(::Graph, ::Int)
rmvertex!(::Graph, ::AbstractVector{Int})
rmedge!(::Graph, ::Pair{Int,Int})
```
