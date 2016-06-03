################################################# FILE DESCRIPTION #########################################################

# This file contains the AdjacencyModule interface. The AdjacencyModule is expted to store all the structural information 
# contained in the graph. The Adjacency module Integer indices to refer to vertices, in order to keep accesses fast.
 
################################################# IMPORT/EXPORT ############################################################
import Base: size
export 
# Types
AdjacencyModule,
# Constants
Adjacency_Interface_Methods,
# AdjacencyModule Interface
nv, ne, fadj, badj, addvertex!, rmvertex!, addedge!, rmedge!

abstract AdjacencyModule

################################################# INTERFACE ################################################################

const Adjacency_Interface_Methods = [:nv, :ne, :size, :fadj, :badj, :addvertex!, :rmvertex!, :addedge!, :rmedge!]

""" The number of vertices in the graph """
@interface nv(x::AdjacencyModule)

""" The number of edges in the graph """
@interface ne(x::AdjacencyModule)

""" Return V x E """
@interface size(x::AdjacencyModule)

""" Vertex v's out-neighbors in the graph """
@interface fadj(x::AdjacencyModule, v::VertexID)

""" Vertex v's in-neighbors in the graph """
@interface badj(x::AdjacencyModule, v::VertexID)

""" Add a vertex to the graph """
@interface addvertex!(x::AdjacencyModule)

""" Remove a vertex from the graph """
@interface rmvertex!(x::AdjacencyModule, v::VertexID)
""" Add an edge u->v to the graph """
@interface addedge!(x::AdjacencyModule, u::VertexID ,v::VertexID)
""" Remove edge u->v from the graph """
@interface rmedge!(x::AdjacencyModule, u::VertexID, v::VertexID)


################################################# IMPLEMENTATIONS #########################################################

include("lightgraphs/adjacencymodule.jl")

include("sparse/adjacencymodule.jl")