## Vertex Metadata

Graft supports the assignment of metadata to vertices, and adopts a tabular approach
to storage. Vertex metadata is stored as an `AbstractDataFrame`. The vertices
internal identifiers are used to index the vertex table.

The following example demonstrates vertex metadata:

```@repl
using Graft

g = completegraph(10);
setlabel!(g, map(string, 1:10));

# Create a new vertex property
setvprop!(g, :, 1 : 10, :p1);

# Fetch an entire column from the vertex table
getvprop(g, :, :p1)

# Modify the property's value for a subset of the vertices
setvprop!(g, 1:5, 5, :p1)

# Fetch the property's value for a subset of the vertices
getvprop(g, 1:5, :p1)

# Create a new vertex property
setvprop!(g, :, 1, :p2);

# List all vertex properties in the graph
listvprops(g)

# Display the vertex table
V = VertexDescriptor(g)

# Examine a single labelled vertex
V["5"]
```

Detailed documentation:
```@docs
listvprops
hasvprop
getvprop
setvprop!
```
