################################################# FILE DESCRIPTION ##########################################################

# This file contains the combinatorial API for Graph.

################################################# IMPORT/EXPORT #############################################################

export nv, ne, vertices, edges, hasvertex, hasedge, fadj, fadj!, outdegree, indegree

################################################# COMBINATORIAL BASICS ######################################################

""" Return nv(g) x ne(g) """
Base.size(g::Graph) = (g.nv,g.ne)


""" The list of the vertices in the graph """
vertices(g::Graph) = 1 : nv(g)


""" Returns an edge iterator containing all edges in the graph """
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

"""
Retrieve a list of vertices connect to vertex v.

This method copies the adjacencies onto the input array,
and is comparitively faster, and causes no mallocs.
"""
fadj!(g::Graph, v::VertexID, adj::Vector{Int}) = fadj!(indxs(g), v, adj)


""" Vertex v's outdegree in the graph """
outdegree(g::Graph, v::VertexID) = outdegree(indxs(g), v)

""" Outdegree of vertex v for v in vs """
outdegree(g::Graph, vs::VertexList) = outdegree(indxs(g), vs)

""" Outdegrees of all the vertices in the graph """
outdegree(g::Graph) = outdegree(indxs(g))


""" Vertex v's indegree in the graph """
indegree(g::Graph, v::VertexID) = indegree(indxs(g), v)

""" Indegree of vertex v for v in vs """
indegree(g::Graph, vs::VertexList) = indegree(indxs(g), vs)

""" Indegrees of all the vertices in the graph """
indegree(g::Graph) = indegree(indxs(g))


""" Shorcut to vertex v's out-neighbors in the graph """
function Base.getindex(g::Graph, v)
   encode(g, fadj(g, decode(g, v)))
end
