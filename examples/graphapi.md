# Graft: A graph toolkit for Julia


## Introduction to Graft queries
Graft's query notation is borrowed from [Jplyer](https://github.com/davidagold/jplyr.jl). The `@query` macro is used to simplify the query syntax, and
accepts a pipeline of abstractions separated by the pipe operator `|>`. The stages are described through abstractions:


### `eachvertex`
Accepts a vertex expression, that is run over every vertex. Vertex properties can be
expressed using the dot notation. Some reserved properties are `v.label`, `v.indegree` and `v.outdegree`.
Examples:
```julia
g |> eachvertex(v.p1 + v.p2) # Sums of properties p1 and p2 for each vertex.
g |> eachvertex(v.outdegree - v.indegree) # Checks if vertices are balanced
```

### `eachedge`
Accepts an edge expression, that is run over every edge. The symbol `s` is used to denote
the source vertex, and `t` is used to denote the target vertex in the edge. The symbol `e` is used to denote
the edge itself. Edge properties can be expressed through the dot notation.
Examples:
```julia
g |> eachedge(e.p1 - s.p1 - t.p1) # arithmetic expression on edge and constituent vertices' properties
g |> eachedge(s.outdegree == t.outdegree) # Checks if constituent vertices have the same outdegree
```

### `filter`
Accepts vertex or edge expressions and computes subgraphs with a subset of vertices, or a subset
of edges, or both.
Examples:
```julia
g |> filter(v.p1 != v.p2)  # Remove vertices where property p1 equals property p2
g |> filter(e.capacity < e.flow) # edges in a flow network that can be augmented
```

### `select`
Returns a subgraph with a subset of vertex properties, or a subset of edge properties or both.
Examples:
```julia
g |> select(v.p1, v.p2) # preserve vertex properties p1, p2 and nothing else
g |> select(v.p1, e.p2) # preserve vertex property p1 and edge property p2
```

## Query examples
This section contains a detailed example, demonstrating the typical workflow Graft aims to support. The dataset used here, [Google+](http://snap.stanford.edu/data/egonets-Gplus.html), was obtained from the Stanford Network Analysis Platform,
Reference : `J. McAuley and J. Leskovec. Learning to Discover Social Circles in Ego Networks. NIPS, 2012.`

DataSet summary:
* vertices : 107614
* edges : 51127

The Google+ data is essentially a network of professionals across the world. Each vertex or person,
has the following attributes attached:

1. gender: 1 for male and 2 for female, 0 if unspecified
2. institute: An array containing keywords describing the person's workplace
3. job_title: An array containing keywords describing the person's role
4. last_name
5. place: An array containing places the person has worked/lived
6. university

The dataset is in the form of a ego-network, and contains a set of files for each ego-node:
1. nodeId.edges : The edges in the ego network for the node 'nodeId'. The 'ego' node does not appear, but it is assumed that they
follow every node id that appears in this file.
2. nodeId.feat : The features for each of the nodes that appears in the edge file.
3. nodeId.egofeat : The features for the ego user.
4. nodeId.featnames : The names of each of the feature dimensions. Features are '1' if the user has this property in their profile, and '0' otherwise.

The structure of the vertex metadata is quite awkward, but nothing a bit of preprocessing can't handle:

```julia
using Graft
using StatsBase
import LightGraphs

julia> # Fetch the dataset
       # Uncompress the vertex metadata and convert to TSV
       # Write the vertex metadata to vertex_data.txt
       # Initialize the graph file, Graph.txt, with a header
       include("build_dataset.jl")

shell> # Remove duplicate vertex entries
       awk '!seen[$1]++' vertex_data.txt > vdata.txt

shell> # Remove duplicate edge entries and convert to TSV
       awk '!seen[$0]++' gplus_combined.txt | tr ' ' '\t' > edata.txt

shell> # Copy the metadata and edge data into the graph file
       cat vdata.txt edata.txt >> Graph.txt

julia> # The graph dataset is now stored in Graph.txt
       countlines("Graph.txt")

```

Graft provides the `loadgraph` method to extract graphs from files, but it supports only a form of TSV at the moment:

```julia

julia> g = loadgraph("Graph.txt"; verbose=true)
Graph(107614 vertices, 13673453 edges, Symbol[:gender,:institution,:job_title,:last_name,:place,:university] vertex properties, Symbol[] edge properties)

julia> # Get the graph's size
       size(g)
(107614,13673453)
```

Now that the graph is loaded into memory, we can start mining interesting information from the graph:

```julia
julia> # Function to fetch the 5 most frequent entries
       top5(x::Vector) = sort(collect(countmap(x)), by=x->x[2], rev=true)[1 : 5]

julia> # Find the universities where alumni are well connected
       vcat(@query(g |> filter(s.university == t.university) |> eachedge(s.university))...) |> top5
5-element Array{Pair{String,Int64},1}:
   "Stanford University"=>452
   "Polytechnic University of Puerto Rico"=>105
   "East Carolina University"=>91
   "University of Utah"=>86
   "Colorado State University"=>84

julia> # If you work for Google, which schools did people in your network go to?
       network = hopgraph(g, @query(g |> filter("Google" in v.institution) |> eachvertex(v.label)), 1)
       vcat(@query(network |> eachvertex(v.university))...) |> top5
5-element Array{Pair{String,Int64},1}:
   "Stanford University"=>182
   "University of California, Berkeley"=>103
   "University of Phoenix"=>87
   "University of Michigan"=>82
   "Harvard University"=>75

julia> # Find the most popular schools in Los Angeles
       unis = vcat(@query(g |> filter("Los Angeles" in v.place) |> eachvertex(v.university))...)
       top5(unis)
5-element Array{Pair{String,Int64},1}:
   "University of Southern California"=>13
   "University of California, Los Angeles"=>12
   "University of California, Berkeley"=>8
   "Columbia University"=>7
   "New York University"=>7

julia> # Which cities are the most connect to New York?
       places = @query(g |> filter("New York" in s.place) |> eachedge(t.place))
       top5(places)
5-element Array{Pair{String,Int64},1}:
   "London"=>2105
   "New York"=>1577
   "San Francisco, CA"=>1381
   "Chicago, IL"=>1163
   "San Francisco"=>1131
```
