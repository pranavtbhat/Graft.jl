# ##
# This file contains a detailed example, demonstrating the typical workflow
# Graft aims to support.
# The dataset used here was obtained form the Stanford Network Analysis Platform.
# Google+ - http://snap.stanford.edu/data/egonets-Gplus.html
# References :
# 1. J. McAuley and J. Leskovec. Learning to Discover Social Circles in Ego Networks. NIPS, 2012.
#
# DataSet summary:
# vertices : 107614
# edges : 13673453
# vertex properties: gender, institute, job_title, last_name, place, university
# ##

using Graft
using StatsBase
import LightGraphs

## Load and summarize the graph
g = loadgraph(joinpath(Pkg.dir("Graft"), "examples/Graph.txt"))

# Get the graph's size
size(g)

# Get an edge iterator for g
edges(g)

# List vertex labels
encode(g)

# List vertex properties
listvprops(g)

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
