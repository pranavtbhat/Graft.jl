################################################# FILE DESCRIPTION #########################################################

# This file contains the AdjacencyModule interface. The AdjacencyModule is expted to store all the structural information 
# contained in the graph. The Adjacency module Integer indices to refer to vertices, in order to keep accesses fast.
 
################################################# IMPORT/EXPORT ############################################################
import Base: size
export 
# Types
AdjacencyModule,
# AdjacencyModule Interface
nv, ne, fadj, badj, addvertex!, rmvertex!, addedge!, rmedge!

abstract AdjacencyModule

################################################# INTERFACE ################################################################

""" The number of vertices in the graph """
@interface nv(g::Graph)

""" The number of edges in the graph """
@interface ne(g::Graph)

""" Return V x E """
@interface size(g::Graph)

""" Vertex v's out-neighbors in the graph """
@interface fadj(g::Graph, v::VertexID)

""" Vertex v's in-neighbors in the graph """
@interface badj(g::Graph, v::VertexID)

""" Add a vertex to the graph """
@interface addvertex!(g::Graph)

""" Remove a vertex from the graph """
@interface rmvertex!(g::Graph, v::VertexID)

""" Add an edge u->v to the graph """
@interface addedge!(g::Graph, u::VertexID ,v::VertexID)

""" Remove edge u->v from the graph """
@interface rmedge!(g::Graph, u::VertexID, v::VertexID)

################################################# IMPLEMENTATIONS #########################################################

include("lightgraphs/adjacencymodule.jl")

include("sparse/adjacencymodule.jl")