################################################# FILE DESCRIPTION #########################################################

# This file contains the AdjacencyModule interface. The AdjacencyModule is expted to store all the structural information 
# contained in the graph. The Adjacency module uses Integer indices to refer to vertices, in order to keep accesses fast.
 
################################################# IMPORT/EXPORT ############################################################
import Base: size
export 
# Types
AdjacencyModule,
# AdjacencyModule Interface
nv, ne, vertices, edges, hasvertex, hasedge, fadj, badj, outdegree, indegree, addvertex!, rmvertex!, addedge!, rmedge!

abstract AdjacencyModule

################################################# INTERFACE ################################################################

@interface Base.deepcopy(x::AdjacencyModule)

@interface nv(x::AdjacencyModule)
@interface ne(x::AdjacencyModule)
@interface Base.size(x::AdjacencyModule)

@interface vertices(x::AdjacencyModule)
@interface edges(x::AdjacencyModule)

@interface hasvertex(x::AdjacencyModule, v::VertexID)
@interface hasedge(x::AdjacencyModule, u::VertexID, v::VertexID)
@interface hadedge(x::AdjacencyModule, e::EdgeID)
@interface fadj(x::AdjacencyModule, v::VertexID)
@interface badj(x::AdjacencyModule, v::VertexID)
@interface outdegree(x::AdjacencyModule, v::VertexID)
@interface indegree(x::AdjacencyModule, v::VertexID)

@interface addvertex!(x::AdjacencyModule, num::Int=1)

@interface rmvertex!(x::AdjacencyModule, vs)

@interface addedge!(x::AdjacencyModule, u::VertexID ,v::VertexID)
@interface addedge!(x::AdjacencyModule, e::EdgeID)
@interface addedge!(x::AdjacencyModule, elist::AbstractVector{EdgeID})

@interface rmedge!(x::AdjacencyModule, u::VertexID, v::VertexID)
@interface rmedge!(x::AdjacencyModule, e::EdgeID)
@interface rmedge!(x::AdjacencyModule, e::AbstractVector{EdgeID})

import Base: ==
(==)(x::AdjacencyModule, y::AdjacencyModule) = vertices(x) == vertices(y) && collect(edges(x)) == collect(edges(y))

################################################# SUBGRAPH ################################################################

@interface subgraph(x::AdjacencyModule, vlist::AbstractVector{VertexID})

@interface subgraph(x::AdjacencyModule, elist::AbstractVector{EdgeID})

################################################# IMPLEMENTATIONS #########################################################

if CAN_USE_LG
   include("adjmods/lightgraphs.jl")
end

include("adjmods/sparsematrix.jl")

