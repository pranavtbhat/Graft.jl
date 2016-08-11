# Labelling

By default, a vertex is identified by its internal identifier. However, a user
can assign labels of any arbitrary Julia type to identify vertices. However, these
labels can be used only externally. Internally, the vertices will still be identified
by their integer ids. This is done has vertex label resolution can impose a significant
overhead.

The following example demonstrates the Labelling API:

```@repl
using Graft

g = completegraph(10)

# Set labels "1", "2" ... "10" to the vertices
setlabel!(g, map(string, 1 : 10))

# Translate labels into vertex identifiers
decode(g, "1")

# Decode a labelled edge
decode(g, "1"=>"2")

# Translate vertex identifiers into labels
encode(g, 1)

# Encode an edge
encode(g, 1=>2)

# Relabel a vertex
relabel!(g, 1, "ONE")

# Remove all vertex labels (Use vertex identifiers instead)
setlabel!(g)

# Display all vertex labels (defaults to vertex identifiers in this case)
encode(g)
```

Detailed documentation:
```@docs
setlabel!(::Graph, ::Vector)
setlabel!(::Graph)
decode(::Graph, ::Any)
decode(::Graph, ::Pair)
encode(::Graph, ::Int)
encode(::Graph, ::Pair{Int,Int})
encode(::Graph)
relabel!(::Graph, ::Int, ::Any)
relabel!(::Graph, ::AbstractVector{Int}, ::Vector)
```
