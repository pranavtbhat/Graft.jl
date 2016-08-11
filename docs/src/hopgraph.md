# Hop Subgraphs

Graft provides methods to construct subgraphs using traversals. Consider the following example:

```@repl
using Graft

g = Graph(20, 60)
setlabel!(g, map(string, 1 : 20))

# Get a list of vertices, at a distance of 2-3 hops from vertex "1"
hoplist(g, "1", 2, 3)

# Get a BFS tree starting from the input vertex
# and terminating at 3 hops distance. Can be used to visualize
# a BFS traversal
hoptree(g, "1", 3)

# Get a subgraph containing all vertices within 3 hops distance,
# and all edges between them. Can be used to construct the
# neighborhood of a vertex
hopgraph(g, "1", 3)
```

Detailed documentation:
```@docs
hoplist
hoptree
hopgraph
```
