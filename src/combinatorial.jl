################################################# FILE DESCRIPTION ##########################################################

# This file contains the combinatorial API for Graph.

################################################# IMPORT/EXPORT #############################################################
export
nv, ne, vertices, edges, hasvertex, hasedge, fadj, badj, out_neighbors, in_neighbors, outdegree, indegree, addvertex!,
rmvertex!, addedge!, rmedge!

################################################# COMBINATORIAL BASICS ######################################################

""" Return V x E """
Base.size(g::Graph) = (g.nv,g.ne)


""" Return a list of the vertices in the graph """
vertices(g::Graph) = 1 : nv(g)


""" A list of edges in the graph """
edges(g::Graph) = EdgeIter(indxs(g))


""" Check if the vertex(s) exists """
hasvertex(g::Graph, v::VertexID) = 1 <= v <= nv(g)
hasvertex(g::Graph, vs::VertexList) = 1 .<= vs .<= nv(g)


""" Check if the edge(s) exists """
hasedge(g::Graph, e::EdgeID) = indxs(g)[e] > 0
hasedge(g::Graph, es::EdgeList) = indxs(g)[es] .> 0

################################################# ADJACENCY #################################################################

""" Vertex v's out-neighbors in the graph """
fadj(g::Graph, v::VertexID) = fadj(indxs(g), v)
fadj!(g::Graph, v::VertexID, adj::Vector{Int}) = fadj!(indxs(g), v, adj)


""" Vertex v's outdegree in the graph """
outdegree(g::Graph, v::VertexID) = outdegree(indxs(g), v)


""" Vertex v's indegree in the graph """
indegree(g::Graph, v::VertexID) = indegree(indxs(g), v)

###
# GRAPH GETINDEX FOR ADJ
###
function Base.getindex(g::Graph, v)
   encode(g, fadj(g, decode(g, v)))
end
