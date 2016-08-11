# EdgeIteration
Graft provides the `EdgeIter` type for fast, alloc-free edge iteration. This type
simplifies the indexing and construction of sparse matrices.

The following example demonstrates the usage of `EdgeIter`:

```@repl
using Graft

g = completegraph(3)

# Build an iterator for all edges in the graph
eit = edges(g)

# Iterate through edges
for e in eit
   # Do something here
end

# Use in list comprehensions
[e for e in eit]

# Get the third edge in the graph
eit[3]

# Get a subset of the edges in the graph (returns a new iterator)
eit[1:3]

# Concatenate two iterators
vcat(eit[4:6], eit[1:3])

# Edge iterator implements the AbstractVector{Pair{Int,Int}} interface
sort(ans)
```

Detailed documentation:
```@docs
EdgeIter
getindex(::EdgeIter, ::Int)
getindex(::EdgeIter, ::AbstractVector{Int})
getindex(::EdgeIter, ::Colon)
vcat(::EdgeIter, ::EdgeIter)
```
