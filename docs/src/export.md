# Export API

Graft supports the export of adjacency matrices and metadata, for use in
Graph libraries such as LightGraphs. The example below shows how a workflow
involving LightGraphs algorithms may look like.

```julia
using Graft
import LightGraphs

g = Graph(10^3, 5 * 10^4);
setlabel!(g, map(string, 1 : 10^3));

julia> # Set edge properties
       seteprop!(g, :, rand(ne(g)), :weight);

julia> seteprop!(g, :, rand(1 : 10, ne(g)), :dist);


julia> # Discard low weight edges
       g = @query(g |> filter(e.weight >= 0.5))
Graph(1000 vertices, 24939 edges, Symbol[] vertex properties, Symbol[:weight,:dist] edge properties)

julia> # Export g's adjacency matrix
       M = export_adjacency(g)
 1000×1000 sparse matrix with 24939 Int64 nonzero entries:
 	[33  ,    1]  =  1
 	[63  ,    1]  =  2
 	[131 ,    1]  =  3
 	[161 ,    1]  =  4
 	[224 ,    1]  =  5
 	[339 ,    1]  =  6
 	[380 ,    1]  =  7
 	[491 ,    1]  =  8
 	[667 ,    1]  =  9
 	⋮
 	[524 , 1000]  =  24931
 	[615 , 1000]  =  24932
 	[624 , 1000]  =  24933
 	[628 , 1000]  =  24934
 	[638 , 1000]  =  24935
 	[846 , 1000]  =  24936
 	[870 , 1000]  =  24937
 	[871 , 1000]  =  24938
 	[956 , 1000]  =  24939

julia> # Export g's edge dists
       D = export_edge_property(g, :dist)
 1000×1000 sparse matrix with 24939 Int64 nonzero entries:
 	[33  ,    1]  =  4
 	[63  ,    1]  =  4
 	[131 ,    1]  =  4
 	[161 ,    1]  =  4
 	[224 ,    1]  =  4
 	[339 ,    1]  =  8
 	[380 ,    1]  =  6
 	[491 ,    1]  =  1
 	[667 ,    1]  =  8
 	⋮
 	[615 , 1000]  =  5
 	[624 , 1000]  =  3
 	[628 , 1000]  =  5
 	[638 , 1000]  =  2
 	[846 , 1000]  =  1
 	[870 , 1000]  =  7
 	[871 , 1000]  =  5
 	[956 , 1000]  =  4

julia> # Construct a LightGraphs graph
       lg = LightGraphs.DiGraph(M)
{1000, 24939} directed graph

julia> # Calculate all pair shortest paths
       sdists = LightGraphs.floyd_warshall_shortest_paths(lg, D).dists
1000×1000 Array{Int64,2}:
5  5  4  5  6  6  6  6  6  6  6 … 4  6  4  6  5  6  4  5  7  5  3  6
6  7  7  6  6  7  7  4  6  4  6   6  7  2  6  7  6  6  6  7  6  5  6
7  6  7  5  8  5  6  7  6  7  5   5  7  6  6  7  7  8  5  7  6  6  7
5  7  5  4  7  6  6  7  6  6  5 … 6  6  3  6  5  4  7  6  6  7  5  5
4  7  7  3  7  5  7  6  2  4  6   4  6  5  6  5  7  7  7  6  6  6  6
7  7  7  5  7  6  7  6  5  4  5   4  7  7  6  6  8  6  6  6  5  6  5
7  6  7  6  8  5  7  7  8  8  6 … 7  7  7  6  8  8  9  7  9  7  7  5
7  4  7  5  4  5  4  6  6  8  6   4  7  6  5  7  6  7  6  6  5  7  5
7  6  6  7  4  5  5  6  7  9  6   7  4  6  6  7  7  6  6  7  7  5  7
7  5  7  5  6  5  7  5  6  5  6 … 5  6  5  4  4  6  7  4  7  5  5  3
5  3  6  5  7  5  6  4  6  7  6   5  6  4  6  5  5  4  5  6  7  5  6
4  5  6  5  5  5  6  5  3  4  6   5  6  3  7  6  7  6  6  5  4  5  6
⋮     ⋮      ⋮     ⋮      ⋮      ⋱    ⋮     ⋮      ⋮     ⋮     ⋮      ⋮
8  8  5  6  7  6  6  3  6  4  7   7  6  6  7  4  5  3  8  3  5  6  4
7  7  6  7  4  3  6  5  7  5  5   6  5  7  5  4  6  5  7  4  6  7  6
6  7  7  7  5  7  6  3  5  7  7 …  7  5  6  6  5  7  5  6  5  6  5  5
6  6  7  7  6  3  5  6  5  7  4   7  7  5  5  3  6  5  7  7  6  7  4
8  7  5  5  4  7  7  6  6  7  8   8  8  5  5  7  5  8  6  7  4  7  8
6  6  6  7  5  6  5  6  4  6  5 … 6  7  7  6  3  8  5  8  6  5  7  6
7  6  6  5  5  5  6  6  7  7  5   6  7  6  5  3  5  5  8  5  5  6  6
6  7  5  6  7  6  6  6  7  6  7   3  4  8  5  6  6  4  5  7  5  4  5
9  9  7  9  7  8  7  6  9  9  7 … 9  6  9  9  8  8  6  9  7  7  0  7
8  8  8  7  7  8  6  7  8  7  8   8  8  4  6  8  7  7  9  8  8  9  8
6  5  6  6  3  5  7  6  7  6  6   7  7  7  5  4  7  7  7  6  7  4  8
7  6  6  4  6  6  4  5  7  7  6 … 7  6  5  6  3  6  5  5  6  5  8  6

julia> # Find the shortest distances for edge pairs
       sdists = [sdists[e.second, e.first] for e in edges(g)];

julia> # Make the shortest distances an edge proeprty
       seteprop!(g, :, sdists, :shortest_distance);

julia> # Calculate the graph's betweenness centrality
       centrality = LightGraphs.betweenness_centrality(lg);

julia> # Make the centrality calculate above a vertex property
       setvprop!(g, :, centrality, :centrality)

julia> # Display the vertex table
       VertexDescriptor(g)
 │ VertexID │ Labels │ centrality  │
 ├──────────┼────────┼─────────────┤
 │ 1        │ 1      │ 0.00100559  │
 │ 2        │ 2      │ 0.00115523  │
 │ 3        │ 3      │ 0.00139773  │
 │ 4        │ 4      │ 0.00161647  │
 │ 5        │ 5      │ 0.00184465  │
 │ 6        │ 6      │ 0.00152136  │
 │ 7        │ 7      │ 0.00113189  │
 │ 8        │ 8      │ 0.00147083  │
 ⋮
 │ 990      │ 990    │ 0.00233637  │
 │ 991      │ 991    │ 0.00101592  │
 │ 992      │ 992    │ 0.00152453  │
 │ 993      │ 993    │ 0.00124928  │
 │ 994      │ 994    │ 0.000931563 │
 │ 995      │ 995    │ 0.00144064  │
 │ 996      │ 996    │ 0.0008423   │
 │ 997      │ 997    │ 0.00114039  │
 │ 998      │ 998    │ 0.00172091  │
 │ 999      │ 999    │ 0.00131404  │
 │ 1000     │ 1000   │ 0.00128859  │

juila> # Display the edge table for edges where a shorter distance was found
       EdgeDescriptor(@query(g |> filter(e.dist != e.shortest_distance)))
 │ Index │ Source │ Target │ weight   │ dist │ shortest_distance │
 ├───────┼────────┼────────┼──────────┼──────┼───────────────────┤
 │ 1     │ 1      │ 339    │ 0.544382 │ 8    │ 5                 │
 │ 2     │ 1      │ 667    │ 0.983177 │ 8    │ 7                 │
 │ 3     │ 1      │ 701    │ 0.510004 │ 7    │ 6                 │
 │ 4     │ 1      │ 744    │ 0.678528 │ 10   │ 3                 │
 │ 5     │ 1      │ 772    │ 0.89435  │ 10   │ 8                 │
 │ 6     │ 2      │ 98     │ 0.999188 │ 9    │ 8                 │
 │ 7     │ 2      │ 237    │ 0.578166 │ 10   │ 7                 │
 │ 8     │ 2      │ 301    │ 0.560192 │ 9    │ 6                 │
 │ 9     │ 2      │ 476    │ 0.602794 │ 8    │ 7                 │
 │ 10    │ 2      │ 525    │ 0.973554 │ 9    │ 5                 │
 │ 11    │ 2      │ 736    │ 0.828569 │ 8    │ 5                 │
 │ 12    │ 2      │ 877    │ 0.620037 │ 8    │ 5                 │
 ⋮
 │ 10367 │ 998    │ 840    │ 0.941186 │ 8    │ 4                 │
 │ 10368 │ 999    │ 78     │ 0.665393 │ 5    │ 3                 │
 │ 10369 │ 999    │ 281    │ 0.878904 │ 9    │ 6                 │
 │ 10370 │ 999    │ 350    │ 0.628088 │ 6    │ 5                 │
 │ 10371 │ 999    │ 528    │ 0.699302 │ 10   │ 6                 │
 │ 10372 │ 999    │ 653    │ 0.860554 │ 9    │ 5                 │
 │ 10373 │ 999    │ 715    │ 0.74898  │ 9    │ 7                 │
 │ 10374 │ 999    │ 726    │ 0.772087 │ 9    │ 5                 │
 │ 10375 │ 999    │ 862    │ 0.852327 │ 7    │ 5                 │
 │ 10376 │ 999    │ 947    │ 0.907081 │ 7    │ 5                 │
 │ 10377 │ 1000   │ 370    │ 0.916611 │ 9    │ 6                 │
 │ 10378 │ 1000   │ 375    │ 0.902912 │ 8    │ 4                 │
 │ 10379 │ 1000   │ 390    │ 0.523391 │ 7    │ 5                 │
 │ 10380 │ 1000   │ 421    │ 0.673928 │ 9    │ 5                 │
```

Detailed Documentation:
```@docs
export_adjacency
export_vertex_property
export_edge_property
```
