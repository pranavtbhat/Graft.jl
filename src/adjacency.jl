################################################# FILE DESCRIPTION #########################################################

# This file contains the AdjacencyModule interface. The AdjacencyModule is expted to store all the structural information 
# contained in the graph. The Adjacency module Integer indices to refer to vertices, in order to keep accesses fast.
 
################################################# IMPORT/EXPORT ############################################################
import Base: size
export 
# Types
AdjacencyModule,
# AdjacencyModule Interface
nv, ne, vertices, edges, hasedge, fadj, badj, addvertex!, rmvertex!, addedge!, rmedge!

abstract AdjacencyModule

################################################# INTERFACE ################################################################


@interface nv(x::AdjacencyModule)
@interface ne(x::AdjacencyModule)
@interface size(x::AdjacencyModule)
@interface vertices(x::AdjacencyModule)
@interface edges(x::AdjacencyModule)
@interface hasedge(x::AdjacencyModule, u::VertexID, v::VertexID)
@interface fadj(x::AdjacencyModule, v::VertexID)
@interface badj(x::AdjacencyModule, v::VertexID)
@interface addvertex!(x::AdjacencyModule)
@interface rmvertex!(x::AdjacencyModule, v::VertexID)
@interface addedge!(x::AdjacencyModule, u::VertexID ,v::VertexID)
@interface rmedge!(x::AdjacencyModule, u::VertexID, v::VertexID)

################################################# SUBGRAPH ################################################################

@interface subgraph(x::AdjacencyModule, vlist::AbstractVector{VertexID})



################################################# IMPLEMENTATIONS #########################################################

include("lightgraphs/adjacencymodule.jl")

include("sparse/adjacencymodule.jl")

