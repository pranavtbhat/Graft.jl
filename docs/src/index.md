# ParallelGraphs Documentation

```@contents
```

## Type Aliases
```@docs
VertexID
EdgeID
VertexList
EdgeList
```
<!-- #################################################################################################################### -->

## The Graph datastructure

The Graph datatype is the core datastructure used in Graft.jl. The Graph datatype has the following fields:
1. nv     : The number of vertices in the graph.
2. ne     : The number of edges int he graph.
3. indxs  : The adjacency matrix for the graph. The SparseMatrixCSC type is used here, both
            as an adjacency matrix and as an index table, that maps edges onto their entries in the
            edge dataframe.
4. vdata  : A dataframe used to store vertex data. This dataframe is indexed by the internally used
            vertex identifiers.
5. edata  : An edge dataframe used to store edge data. This dataframe is indexed by indxs datastructure.
6. lmap   : A label map that maps externally used labels onto the internally used vertex identifiers and vice versa.

### Accessors
```@docs
nv
ne
indxs
vdata
edata
lmap
```

### Construction
The following methods can be used to construct unlabelled graphs:
```@docs
emptygraph
randgraph
completegraph
```

Labelled graphs can be build using the constructors:
```@docs
Graph(::Int, ::Vector)
Graph(::Int, ::Vector, ::Int)
```

### Combinatorial stuff
Basic methods on graph structure:
```@docs
vertices
edges
hasvertex
hasedge
```

Adjacency queries:
```@docs
fadj
fadj!
outdegree
indegree
```

### Graph mutations
Graphs can be modified using the following methods:
```@docs
addvertex!(::Graph)
addvertex!(::Graph, ::Any)
addedge!(::Graph, ::Pair{Int,Int})
rmvertex!(::Graph, ::Int)
rmvertex!(::Graph, ::AbstractVector{Int})
rmedge!(::Graph, ::Pair{Int,Int})
```

### Labelling
New labels can be added or removed through the following methods:
```@docs
setlabel!(::Graph, ::Vector)
setlabel!(::Graph, ::Symbol)
setlabel!(::Graph)
```

Labels can be modified through the following methods:
```@docs
relabel!(::Graph, ::Int, ::Any)
relabel!(::Graph, ::AbstractVector{Int}, ::Vector)
```





<!-- #################################################################################################################### -->

## EdgeIteration
The EdgeIter type provides alloc-free and fast edge iteration.

### Construction
```@docs
edges(::Graph)
```

### Getindex
```@docs
getindex(::EdgeIter, ::Int)
getindex(::EdgeIter, ::AbstractVector{Int})
getindex(::EdgeIter, ::Colon)
```

### Concatenation
```@docs
vcat(::EdgeIter, ::EdgeIter)
```

### Usage
```@example
using ParallelGraphs

g = completegraph(3)

# Construct Iterator
eit = edges(g)

# Iterate through edges
for e in eit
   # Do something here
end

# In list comprehensions
[e for e in eit]
```

<!-- #################################################################################################################### -->
## Metadata

### Setting vertex metadata
```@docs
setvprop!
```

### Retrieving vertex metadata
```@docs
getvprop
```

### Setting edge metadata
```@docs
seteprop!
```

### Retrieving edge metadata
```@docs
geteprop
```

<!-- #################################################################################################################### -->

## Queries

The query macro is used to execute graph queries in a pipelined manner. The pipelining syntax is borrowed from
jplyer, though I hope to use jplyer directly at some point, for lazy execution.

The main functionalities provided by the query macro are:

### eachvertex:
This abstraction is used to run an expression on every vertex in the graph, and retrieve a vector result.

For example, `@query g |> eachvertex(v.p1 + v.p2 * v.p3)` executes the expression `v.p1 + v.p2 * v.p3`
on every vertex in the result from the previous pipeline stage. Here, `v.p1` denotes the value of property
`p1` for every vertex.


### eachedge:
This abstraction is used to run an expression on every vertex in the graph, and retrieve a vector result.

For example, `@query g |> eachedge(e.p1 + s.p1 + t.p1)` executes the expression `e.p1 + s.p1 + t.p1` on
every edge in the graph. Here, 'e.p1' denotes the value of property `p1` for every edge in the graph. Since
each edge has a source vertex `s` and a target vertex `t`, the properties of these vertices can be used in the expression
as shown by `s.p1` and `t.p1`.

### filter
This abstraction is used to compute a subgraph of the input from the previous pipeline stage, on the given conditions.

For example, `@query g |> filter(v.p1 < 5, v.p1 < v.p2, e.p1 > 5)` uses the three filter conditions provided to compute
a subgraph. Currently only binary comparisons are supported, so comparisons like 1 < v.p1 < v.p2 will not work.
Instead you can supply multiple conditions as separate arguments.

### select
This abstraction is used to compute a subgraph of the input from the previous pipeline state, for a subset of vertex and or
edge properties.

For example, `@query g |> select(v.p1, v.p3, e.p1)` preserves only vertex properties `p1`,`p2` and edge property `p1`.



### Examples
The abstractions can be chained together using the pipe notation, so that the output of one stage becomes the input to the next.

```@example
using ParallelGraphs
g = randgraph(10, [:p1, :p2], [:p1, :p2])

# Run a filter using vertex properties
@query g |> filter(0.5 <= v.p1, v.p1 < v.p2)
```

```@example
using ParallelGraphs
g = randgraph(10, [:p1, :p2], [:p1, :p2])

# Run a filter using source and target properties
@query g |> filter(s.p1 < t.p2)
```

```@example
using ParallelGraphs
g = randgraph(10, [:p1, :p2], [:p1, :p2])

# Run filter using edge properties
@query g |> filter(e.p1 < 0.7)
```

```@example
using ParallelGraphs
g = randgraph(10, [:p1, :p2], [:p1, :p2])

# Chain filter expressions
@query g |> filter(v.p1 < v.p2) |> filter(e.p1 < e.p1)
```

```@example
using ParallelGraphs
g = randgraph(10, [:p1, :p2], [:p1, :p2])

# Select properties
@query g |> filter(v.p1 < v.p2) |> select(v.p2, e.p1)
```

```@example
using ParallelGraphs
g = randgraph(10, [:p1, :p2], [:p1, :p2])

# Run an expression on each vertex
@query g |> eachvertex(v.p1 + v.p2)
```

```@example
using ParallelGraphs
g = randgraph(10, [:p1, :p2], [:p1, :p2])

# Run an expression on each edge
@query g |> filter(e.p1 < e.p2) | eachedge(e.p1 + e.p2)
```

The entire query is parsed into a DAG, using a recursive descent parser, and then executed in a bottom up manner. The results of intermediate
nodes, and fetched vertex properties are cached to avoid redundant computations.
