## Edge Metadata

Graft supports the assignment of metadata to vertices, and adopts a tabular approach
to storage. Edge metadata is stored as an `AbstractDataFrame`. The adjacency matrix
stores the row number for each edge, i.e. it serves as an edge to index map, or an
index table to the edge metadata table.

The following example demonstrates edge metadata:

```@repl
using Graft

g = completegraph(10);
setlabel!(g, map(string, 1 : 10));
eit = edges(g);

# Create a new edge property
seteprop!(g, :, 1 : 90, :p1);

# Fetch an entire column from the vertex table
geteprop(g, :, :p1)

# Modify the property's value for a subset of the vertices
seteprop!(g, eit[1:5], 5, :p1)

# Fetch the property's value for a subset of the vertices
geteprop(g, eit[1:5], :p1)

# Create a new vertex property
seteprop!(g, :, 1, :p2);

# List all vertex properties in the graph
listeprops(g)

# Display the edge table
E = EdgeDescriptor(g)

# Examine a single labelled edge
E["1", "5"]
```

Detailed documentation:
```@docs
listeprops
haseprop
geteprop
seteprop!
```
