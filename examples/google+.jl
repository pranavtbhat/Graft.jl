using Graft
using StatsBase
import LightGraphs

# Fetch the dataset
# Uncompress the vertex metadata and convert to TSV
# Write the vertex metadata to vertex_data.txt
# Initialize the graph file, Graph.txt, with a header
include("build_dataset.jl")

# Remove duplicate vertex entries
;awk '!seen[$1]++' vertex_data.txt > vdata.txt

# Remove duplicate edge entries and convert to TSV
;awk '!seen[$0]++' gplus_combined.txt | tr ' ' '\t' > edata.txt

# Copy the metadata and edge data into the graph file
;cat vdata.txt edata.txt >> Graph.txt

# The graph dataset is now stored in Graph.txt
countlines("Graph.txt")


g = loadgraph("Graph.txt"; verbose=true)

size(g)

# Function to fetch the 5 most frequent entries
top5(x) = sort(collect(countmap(vcat(filter(y->length(y) > 0, collect(x))...))), by=x->x[2], rev=true)[1 : 5]

# Find the universities where alumni are well connected
@query(g |> filter(s.university == t.university) |> eachedge(s.university)) |> top5

# If you work for Google, which schools did people in your network go to?
network = hopgraph(g, @query(g |> filter("Google" in v.institution) |> eachvertex(v.label)), 1)
@query(network |> eachvertex(v.university)) |> top5

# Find the most popular schools in Los Angeles
@query(g |> filter("Los Angeles" in v.place) |> eachvertex(v.university)) |> top5

# Which cities are the most connect to New York?
@query(g |> filter("New York" in s.place) |> eachedge(t.place)) |> top5

# Run page rank, using LightGraphs, and set the result as a vertex property
M = export_adjacency(g)
setvprop!(g, :, LightGraphs.pagerank(LightGraphs.DiGraph(M)), :pagerank)

# Show a table containing a subset of vertex properties
VertexDescriptor(@query(g |> select(v.gender, v.last_name, v.pagerank)))

# Find the number of mutual friends between the source and target vertices for each edge
seteprop!(g, :, @query(g |> eachedge(e.mutualcount)), :mutual_friends);
EdgeDescriptor(g)
