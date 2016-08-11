# Queries

The query macro is used to execute graph queries in a pipelined manner.The main functionalities
provided by the query macro are:

## eachvertex:
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

```@repl
using Graft
g = propgraph(10, [:p1, :p2], [:p1, :p2])

# Run a filter using vertex properties
@query g |> filter(0.5 <= v.p1, v.p1 < v.p2)

# Run a filter using source and target properties
@query g |> filter(s.p1 < t.p2)

# Run filter using edge properties
@query g |> filter(e.p1 < 0.7)

# Chain filter expressions
@query g |> filter(v.p1 < v.p2) |> filter(e.p1 < e.p1)

# Select properties
@query g |> filter(v.p1 < v.p2) |> select(v.p2, e.p1)

# Run an expression on each vertex
@query g |> eachvertex(v.p1 + v.p2)

# Run an expression on each edge
@query g |> filter(e.p1 < e.p2) |> eachedge(e.p1 + e.p2)
```

The entire query is parsed into a DAG, using a recursive descent parser, and then executed in a bottom up manner. The results of intermediate
nodes, and fetched vertex properties are cached to avoid redundant computations.
