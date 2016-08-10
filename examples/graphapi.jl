######
##
## This file demonstrates the Graph API for generating graph data. Here we generate a sort of social network
## of 1000 people, with each person begin assigned a name, age and weight. An edge in this social network
## denotes a like-friendship. So we can calculate the number of people a person likes, as well as the number
## of people that like him. We can also find the number of mutual friends in a relationship, and therefore
## the strength of the relationship, and color the edges accordingly.
##
######
using Graft
srand(101)

# Construct a small random graph with approximately 500k edges
g = randgraph(10^3, 10^5)

# Get a range of vertices in g
vertices(g)

# Get an edge iterator for g
edges(g)

# Examine vertex 1's neighbors
g[1]

# Split the graph into vertex and edge descriptors
V,E = g

# Assign a (hopefully unique) name to each vertex in g
V |> @query v.name = randstring()

# Assign an age to each vertex in g
V |> @query v.age = rand(1:100)

# Assign a weight to each vertex in g
V |> @query v.weight = rand(30:100)

# See how many vertices "like" every vertex in g
V |> @query v.likedby = indegree(g, v)

# See how many vertices every vertex in g likes
V |> @query v.likes = outdegree(g, v)

# Count the number of mutual likes for each edge
E |> @query e.mutual_likes = length(intersect(g[u], g[v]))

# Calculate the minimum and maximum mutual likes
min_likes = E |> @query(e.mutual_likes) |> minimum
max_likes = E |> @query(e.mutual_likes) |> maximum

# Assign a normalized strength to each edge
E |> @query e.strength = (e.mutual_likes - $min_likes) / $max_likes

# Now to color these edges, based on strength
function color_edge(s)
   s < 0.1 && return "red"
   s < 0.3 && return "orange"
   s < 0.5 && return "yellow"
   s < 0.8 && return "blue"
   s <= 1 && return "green"
end
E |> @query e.color = $color_edge(e.strength)

# Label the vertices
setlabel!(g, ["v$v" for v in vertices(g)])

# Store the Graph in a file
storegraph(g, "graph.txt")

# Display the Vertex Descriptor
println(V)

# Display the Edge Descriptor
println(E)

# Obtain vertex data relevant to only the first 10 vertices
V[1:10]

# Find the senior citizens in the graph
senior_citizens = V |> @filter 65 <= v.age

# Find people with abnormal weights
abnormal_weights = V |> @filter v.weight < 40 && v.weight > 90

# Find all strong associations
strong_edges = E |> @filter(e.strength > 0.5)

# Isolate a subgraph with only senior citizens and strong associations
h = Graph(senior_citizens, strong_edges)

# Run a bfs to get the set of all vertices reachable from the first vertex
@bfs V "v1"

# See only the names of the people in the subgraph
println(select(V, "weight"))

# See only the colors of the edges in the subgraph
println(select(E, "color"))
