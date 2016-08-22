###
# This file contains a detailed example, demonstrating the typical workflow
# Graft aims to support.
# The dataset used here was constructed by splicing together two separate datasets:
#
# 1. `SOCR Data MLB HeightsWeights`: Heights, ages and weights of Baseball players (Vertex Data). References:
#   * Jarron M. Saint Onge, Patrick M. Krueger, Richard G. Rogers. (2008) Historical trends in height,
#   weight, and body mass: Data from U.S. Major League Baseball players, 1869-1983, Economics & Human
#   Biology, Volume 6, Issue 3, Symposium on the Economics of Obesity, December 2008, Pages 482-488,
#   ISSN 1570-677X, DOI: 10.1016/j.ehb.2008.06.008.
#   * Jarron M. Saint Onge, Richard G. Rogers, Patrick M. Krueger. (2008) Major League Baseball Players'
#   Life Expectancies, Southwestern Social Science Association, Volume 89, Issue 3, pages 817–830,
#   DOI: 10.1111/j.1540-6237.2008.00562.x.
# 2. Advogato Trust Network : Edge weights between 0 and 1. References:
#   * Advogato network dataset -- KONECT, July 2016. [http](http://konect.uni-koblenz.de/networks/advogato)
#   * Paolo Massa, Martino Salvetti, and Danilo Tomasoni. Bowling alone and trust decline in social network
#   sites. In Proc. Int. Conf. Dependable, Autonomic and Secure Computing, pages 658--663, 2009.
#
# The dataset has 6541 vertices, 51127 edges.
# Vertex properties: Age, Height(cm), Weight(kg)
# Edge properties  : Trust(float)
###

using Graft
using StatsBase
import LightGraphs

## Load and summarize the graph.

# Load the graph
download(
 "https://raw.githubusercontent.com/pranavtbhat/Graft.jl/gh-pages/Datasets/baseball.txt",
 joinpath(Pkg.dir("Graft"), "examples/baseball.txt")
)
g = loadgraph(joinpath(Pkg.dir("Graft"), "examples/baseball.txt"))

# Get the graph's size
size(g)

# Get an edge iterator for g
edges(g)

# List vertex labels
encode(g)

# Split the graph into vertex and edge descriptors
V,E = g;

# Display the vertex table
V

# Display the edge table
E

## Run some metadata queries

# Find the average BMI of baseball players
@query(g |> eachvertex(v.Weight / (v.Height / 100) ^ 2)) |> mean

# Find the median height of baseball players in their 20s
@query(g |> filter(v.Age < 30,v.Age >= 20) |> eachvertex(v.Height * 0.0328084)) |> median

# Find the mean age difference in strong relationships
@query(g |> filter(e.Trust > 0.8) |> eachedge(s.Age - t.Age)) |> abs |> mean

# Find fred's 3 hop neighborhood (friends and friends-of-friends and so on)
fred_nhood = hopgraph(g, "fred", 3)

# See how well younger players in fred's neighborhood trust each other
@query(fred_nhood |> filter(v.Age > 30) |> eachedge(e.Trust)) |> mean


## Export data to LightGraphs.jl

# Find the 2 hop neighborhood of 2 separate vertices (multi seed traversal)
sg = hopgraph(g, ["nikolay", "jbert"], 3)

# Generate an edge distance property on the inverse of normalized-trust
dists = @query(sg |> eachedge(1 / e.Trust ));
seteprop!(sg, :, dists, :Dist);

# Trim edges of very high distance
sg = @query(sg |> filter(e.Dist < 10))

# Export the graph's adjacency matrix
M = export_adjacency(sg)
lg = LightGraphs.DiGraph(M)

# Export the edge distance property
D = export_edge_property(sg, :Dist)

# Compute betweenness centrailty
centrality = LightGraphs.betweenness_centrality(lg)

# Set the centrality as a vertex property
setvprop!(sg, :, centrality, :Centrality)

# Apply all pair shortest paths on the graph
apsp = LightGraphs.floyd_warshall_shortest_paths(lg, D).dists;

# Add the new shortest paths as a property to the graph
eit = edges(sg);
seteprop!(sg, :, [apsp[e.second,e.first] for e in eit], :Shortest_Dists);

# Show new vertex descriptor
VertexDescriptor(sg)


# Show the new edge descriptor
EdgeDescriptor(sg)
