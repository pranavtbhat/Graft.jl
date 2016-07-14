######
##
## This file demonstrates the Graph API for generating graph data. Here we generate a sort of social network
## of 1000 people, with each person begin assigned a name, age and weight. An edge in this social network
## denotes a like-friendship. So we can calculate the number of people a person likes, as well as the number
## of people that like him. We can also find the number of mutual friends in a relationship, and therefore
## the strength of the relationship, and color the edges accordingly.
##
######
using ParallelGraphs
srand(101)

# Generate an empty SparseGraph
g = SparseGraph()

# Add a few vertices to it
addvertex!(g, 100)

# Add a couple of edges to it
addedge!(g, 1=>2)
addedge!(g, 2=>3)

# Check the graph's size
size(g)

# Construct a small random graph with approximately 500k edges
g = SparseGraph(10^3, 10^5)

# Get a range of vertices in g
vertices(g)

# Get an edge iterator for g
edges(g)

# Examine vertex 1's neighbors
fadj(g, 1)

# Assign a (hopefully unique) name to each vertex in g
setvprop!(g, :, v->randstring(), "name")

# Assign an age to each vertex in g
setvprop!(g, :, v->rand(1:100), "age")

# Assign a weight to each vertex in g
setvprop!(g, :, v->rand(30:100), "weight")

# See how many vertices "like" every vertex in g
setvprop!(g, :, v->indegree(g, v), "liked by")

# See how many vertices every vertex in g likes
setvprop!(g, :, v->outdegree(g, v), "likes")

# Count the number of mutual likes for each edge
function count_mutual_friends(g, u, v)
   mfu = out_neighbors(g, u)
   mfv = out_neighbors(g, v)
   length(intersect(mfu, mfv))
end
seteprop!(g, :, (u,v)->count_mutual_friends(g, u, v), "mutual likes")

# Assign a normalized strength to each edge
mutual_likes = geteprop(g, :, "mutual likes")
min_likes = minimum(mutual_likes)
max_likes = maximum(mutual_likes)
str(g, u, v) = (geteprop(g, u, v, "mutual likes") - min_likes)/max_likes
seteprop!(g, :, (u,v)->str(g, u, v), "strength")

# Now to color these edges, based on strength
function color_edge(g, u, v)
   s = geteprop(g, u, v, "strength")
   s < 0.1 && return "red"
   s < 0.3 && return "orange"
   s < 0.5 && return "yellow"
   s < 0.8 && return "blue"
   s <= 1 && return "green"
end
seteprop!(g, :, (u,v)->color_edge(g, u, v), "color")

# Label the vertices by name
setlabel!(g, "name")

# Store the Graph in a file
storegraph(g, "graph.txt")

# Split the graph into its descriptors
V, E = g

# Display the Vertex Descriptor
println(V)

# Display the Edge Descriptor
println(E)

# Obtain vertex data relevant to only the first 10 vertices
V[1:10]

# Find the senior citizens in the graph
senior_citizens = filter(V, "65 <= v.age")

# Find people with abnormal weights
abnormal_weights = filter(V, "v.weight < 40 && v.weight > 90")

# Find all strong associations
strong_edges = filter(E, "e.strength > 0.5")

# Isolate a subgraph with only senior citizens and strong associations
h = Graph(senior_citizens, strong_edges)

# Run a bfs to get a subgraph containing all vertices reachable from the first vertex
V,E = bfs_subgraph(h, 1)

# See only the names of the people in the subgraph
println(select(V, "weight"))

# See only the colors of the edges in the subgraph
println(select(E, "color"))
