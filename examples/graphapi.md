# Graft Example

This file contains a detailed example, demonstrating the typical workflow
Graft aims to support.
The dataset used here was constructed by splicing together two separate datasets:

1. `SOCR Data MLB HeightsWeights`: Heights, ages and weights of Baseball players (Vertex Data). References:
  * Jarron M. Saint Onge, Patrick M. Krueger, Richard G. Rogers. (2008) Historical trends in height,
  weight, and body mass: Data from U.S. Major League Baseball players, 1869-1983, Economics & Human
  Biology, Volume 6, Issue 3, Symposium on the Economics of Obesity, December 2008, Pages 482-488,
  ISSN 1570-677X, DOI: 10.1016/j.ehb.2008.06.008.
  * Jarron M. Saint Onge, Richard G. Rogers, Patrick M. Krueger. (2008) Major League Baseball Players'
  Life Expectancies, Southwestern Social Science Association, Volume 89, Issue 3, pages 817–830,
  DOI: 10.1111/j.1540-6237.2008.00562.x.
2. Advogato Trust Network : Edge weights between 0 and 1. References:
  * Advogato network dataset -- KONECT, July 2016. [http](http://konect.uni-koblenz.de/networks/advogato)
  * Paolo Massa, Martino Salvetti, and Danilo Tomasoni. Bowling alone and trust decline in social network
  sites. In Proc. Int. Conf. Dependable, Autonomic and Secure Computing, pages 658--663, 2009.

The dataset has 6541 vertices, 51127 edges.
Vertex properties: Age, Height(cm), Weight(kg)
Edge properties  : Trust(float)

## Load and summarize the graph.
```julia
using Graft
using StatsBase
import LightGraphs

julia> # Load the graph
       download(
         "https://raw.githubusercontent.com/pranavtbhat/Graft.jl/gh-pages/Datasets/graph.txt",
         joinpath(Pkg.dir("Graft"), "examples/graph.txt")
       )
       g = loadgraph(joinpath(Pkg.dir("Graft"), "examples/graph.txt"))
Graph(6541 vertices, 51127 edges, Symbol[:Age,:Height,:Weight] vertex properties, Symbol[:Trust] edge properties)

julia> # Get the graph's size
       size(g)
(6541,51127)

julia> # Get an edge iterator for g
       edges(g)
51127-element Graft.EdgeIter:
  1=>1
  1=>2
  1=>3
  1=>4
  1=>5
  1=>6
  1=>7
  ⋮
  6537=>6537
  6538=>6538
  6539=>1103
  6539=>6539
  6540=>6540
  6541=>167
  6541=>658

julia> # List vertex labels
       encode(g)
 6541-element Array{Any,1}:
  "gc"
  "prigaux"
  "fred"
  "quintela"
  "jgarzik"
  "penso"
  "leviramsey"
  ⋮
  "MachX"
  "seahawk"
  "xchaix"
  "sktrdie"
  "KellyHo"
  "mike1086"
  "thelema"

julia> # Split the graph into vertex and edge descriptors
       V,E = g;

julia> # Display the vertex table
       V
│ VertexID │ Labels          │ Age   │ Height │ Weight  │
├──────────┼─────────────────┼───────┼────────┼─────────┤
│ 1        │ "gc"            │ 26.03 │ 182.88 │ 104.545 │
│ 2        │ "prigaux"       │ 25.43 │ 175.26 │ 84.0909 │
│ 3        │ "fred"          │ 24.51 │ 182.88 │ 93.6364 │
│ 4        │ "quintela"      │ 31.81 │ 193.04 │ 86.3636 │
│ 5        │ "jgarzik"       │ 27.32 │ 185.42 │ 90.9091 │
│ 6        │ "penso"         │ 25.5  │ 185.42 │ 86.3636 │
│ 7        │ "leviramsey"    │ 32.68 │ 182.88 │ 90.9091 │
⋮
│ 6535     │ "MachX"         │ 26.49 │ 190.5  │ 90.9091 │
│ 6536     │ "seahawk"       │ 22.89 │ 190.5  │ 90.9091 │
│ 6537     │ "xchaix"        │ 28.53 │ 177.8  │ 95.4545 │
│ 6538     │ "sktrdie"       │ 25.35 │ 180.34 │ 86.3636 │
│ 6539     │ "KellyHo"       │ 22.34 │ 185.42 │ 95.4545 │
│ 6540     │ "mike1086"      │ 23.45 │ 190.5  │ 86.3636 │
│ 6541     │ "thelema"       │ 29.99 │ 193.04 │ 88.6364 │

julia> # Display the edge table
       E
│ Index │ Source          │ Target          │ Trust     │
├───────┼─────────────────┼─────────────────┼───────────┤
│ 1     │ "gc"            │ "gc"            │ 0.42739   │
│ 2     │ "gc"            │ "prigaux"       │ 0.978998  │
│ 3     │ "gc"            │ "fred"          │ 0.714178  │
│ 4     │ "gc"            │ "penso"         │ 0.999861  │
│ 5     │ "gc"            │ "leviramsey"    │ 0.993962  │
│ 6     │ "gc"            │ "sh"            │ 0.336044  │
│ 7     │ "gc"            │ "fxn"           │ 0.0949308 │
⋮
│ 51121 │ "baris"         │ "barismetin"    │ 0.934414  │
│ 51122 │ "MachX"         │ "arabouma36"    │ 0.059897  │
│ 51123 │ "seahawk"       │ "seahawk"       │ 0.935393  │
│ 51124 │ "xchaix"        │ "xchaix"        │ 0.966611  │
│ 51125 │ "sktrdie"       │ "sktrdie"       │ 0.323029  │
│ 51126 │ "KellyHo"       │ "KellyHo"       │ 0.404737  │
│ 51127 │ "mike1086"      │ "mike1086"      │ 0.370529  │
```

## Run some metadata queries

```julia

julia> # Find the average BMI of baseball players
       @query(g |> eachvertex(v.Weight / (v.Height / 100) ^ 2)) |> mean
26.23778373854929

julia> # Find the median height of baseball players in their 20s
       @query(g |> filter(v.Age < 30,v.Age >= 20) |> eachvertex(v.Height * 0.0328084)) |> median
6.166666864000001

julia> # Find the mean age difference in strong relationships
       @query(g |> filter(e.Trust > 0.8) |> eachedge(s.Age - t.Age)) |> abs |> mean
4.163929464037767

julia> # Find fred's 3 hop neighborhood (friends and friends-of-friends and so on)
       fred_nhood = hopgraph(g, "fred", 3)
Graph(1957 vertices, 29901 edges, Symbol[:Age,:Height,:Weight] vertex properties, Symbol[:Trust] edge properties)

julia> # See how well younger players in fred's neighborhood trust each other
       @query(fred_nhood |> filter(v.Age > 30) |> eachedge(e.Trust)) |> mean
0.5495668265206273
```

## Export data to LightGraphs.jl

```julia

julia> # Find the 2 hop neighborhood of 2 separate vertices (multi seed traversal)
       sg = hopgraph(g, ["nikolay", "jbert"], 3)
Graph(1615 vertices, 23569 edges, Symbol[:Age,:Height,:Weight] vertex properties, Symbol[:Trust] edge properties)

julia> # Generate an edge distance property on the inverse of normalized-trust
       dists = @query(sg |> eachedge(1 / e.Trust ));
       seteprop!(sg, :, dists, :Dist);

juila> # Trim edges of very high distance
       sg = @query(sg |> filter(e.Dist < 10))
Graph(1615 vertices, 22108 edges, Symbol[:Age,:Height,:Weight] vertex properties, Symbol[:Trust,:Dist] edge properties)

julia> # Export the graph's adjacency matrix
       M = export_adjacency(sg)
       lg = LightGraphs.DiGraph(M)
{1615, 22108} directed graph


julia> # Export the edge distance property
 D = export_edge_property(sg, :Dist)
 1615×1615 sparse matrix with 22108 Float64 nonzero entries:
 	[2   ,    1]  =  1.32673
 	[3   ,    1]  =  1.1944
 	[4   ,    1]  =  1.61156
 	[5   ,    1]  =  1.41891
 	[6   ,    1]  =  1.13725
 	[7   ,    1]  =  2.83361
 	⋮
 	[182 , 1612]  =  5.58207
 	[417 , 1612]  =  3.25723
 	[1612, 1612]  =  2.11023
 	[182 , 1613]  =  1.64596
 	[1   , 1614]  =  2.97909
 	[2   , 1614]  =  1.66407
 	[3   , 1615]  =  1.73024

julia> # Compute betweenness centrailty
       centrality = LightGraphs.betweenness_centrality(lg)
 1615-element Array{Float64,1}:
  0.0352864
  0.0180542
  0.0145245
  1.73845e-5
  0.00615578
  0.0232976
  0.00730561
  ⋮
  0.000582392
  0.00283106
  0.000318805
  2.99768e-5
  0.0
  0.0
  0.0
  0.0

julia> # Set the centrality as a vertex property
       setvprop!(sg, :, centrality, :Centrality)

julia> # Apply all pair shortest paths on the graph
       apsp = LightGraphs.floyd_warshall_shortest_paths(lg, D).dists;

julia> # Add the new shortest paths as a property to the graph
       eit = edges(sg);
       seteprop!(sg, :, [apsp[e.second,e.first] for e in eit], :Shortest_Dists);

julia> # Show new vertex descriptor
       VertexDescriptor(sg)
 │ VertexID │ Labels         │ Age   │ Height │ Weight  │ Centrality  │
 ├──────────┼────────────────┼───────┼────────┼─────────┼─────────────┤
 │ 1        │ "lkcl"         │ 30.51 │ 190.5  │ 95.4545 │ 0.0352864   │
 │ 2        │ "chalst"       │ 27.16 │ 187.96 │ 79.5455 │ 0.0180542   │
 │ 3        │ "jrf"          │ 27.23 │ 182.88 │ 81.8182 │ 0.0145245   │
 │ 4        │ "Astinus"      │ 33.77 │ 190.5  │ 81.8182 │ 1.73845e-5  │
 │ 5        │ "halcy0n"      │ 30.8  │ 187.96 │ 90.9091 │ 0.00615578  │
 │ 6        │ "mbp"          │ 24.21 │ 182.88 │ 113.182 │ 0.0232976   │
 │ 7        │ "sulaiman"     │ 33.15 │ 198.12 │ 100.0   │ 0.00730561  │
 ⋮
 │ 1608     │ "netgod"       │ 26.59 │ 185.42 │ 95.4545 │ 0.000582392 │
 │ 1609     │ "hadess"       │ 28.48 │ 175.26 │ 95.4545 │ 0.00283106  │
 │ 1610     │ "largo"        │ 33.57 │ 185.42 │ 88.6364 │ 0.000318805 │
 │ 1611     │ "kazen"        │ 22.52 │ 175.26 │ 84.0909 │ 2.99768e-5  │
 │ 1612     │ "bluets"       │ 31.63 │ 180.34 │ 102.273 │ 0.0         │
 │ 1613     │ "secabeen"     │ 28.56 │ 193.04 │ 90.9091 │ 0.0         │
 │ 1614     │ "nikolay"      │ 23.29 │ 180.34 │ 100.0   │ 0.0         │
 │ 1615     │ "jbert"        │ 31.84 │ 193.04 │ 85.9091 │ 0.0         │

 julia> # Show the new edge descriptor
        EdgeDescriptor(sg)
 │ Index │ Source     │ Target         │ Trust    │ Dist    │ Shortest_Dists │
├───────┼────────────┼────────────────┼──────────┼─────────┼────────────────┤
│ 1     │ "lkcl"     │ "chalst"       │ 0.753731 │ 1.32673 │ 1.32673        │
│ 2     │ "lkcl"     │ "jrf"          │ 0.837243 │ 1.1944  │ 1.1944         │
│ 3     │ "lkcl"     │ "Astinus"      │ 0.620516 │ 1.61156 │ 1.61156        │
│ 4     │ "lkcl"     │ "halcy0n"      │ 0.704766 │ 1.41891 │ 1.41891        │
│ 5     │ "lkcl"     │ "mbp"          │ 0.879317 │ 1.13725 │ 1.13725        │
│ 6     │ "lkcl"     │ "sulaiman"     │ 0.352907 │ 2.83361 │ 2.33345        │
│ 7     │ "lkcl"     │ "crackmonkey"  │ 0.223243 │ 4.47942 │ 3.25504        │
⋮
│ 22102 │ "bluets"   │ "teknix"       │ 0.179145 │ 5.58207 │ 5.58207        │
│ 22103 │ "bluets"   │ "Stevey"       │ 0.307009 │ 3.25723 │ 3.25723        │
│ 22104 │ "bluets"   │ "bluets"       │ 0.473882 │ 2.11023 │ 0.0            │
│ 22105 │ "secabeen" │ "teknix"       │ 0.607547 │ 1.64596 │ 1.64596        │
│ 22106 │ "nikolay"  │ "lkcl"         │ 0.335673 │ 2.97909 │ 2.97909        │
│ 22107 │ "nikolay"  │ "chalst"       │ 0.600938 │ 1.66407 │ 1.66407        │
│ 22108 │ "jbert"    │ "jrf"          │ 0.577956 │ 1.73024 │ 1.73024        │
