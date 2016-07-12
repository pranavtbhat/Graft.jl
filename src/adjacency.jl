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
@interface hasvertex(x::AdjacencyModule, vs)

@interface hasedge(x::AdjacencyModule, u::VertexID, v::VertexID)
@interface hasedge(x::AdjacencyModule, e::EdgeID)
@interface hasedge(x::AdjacencyModule, es)

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

@interface subgraph(x::AdjacencyModule, vlist::AbstractVector{VertexID}, elist::AbstractVector{EdgeID})

################################################# EDGE ITERATION ##########################################################

abstract EdgeIter <: AbstractVector{EdgeID}

################################################# VALIDATION ##############################################################

###
# VERTEX VALIDATION
###
function validate_vertex(x::AdjacencyModule, vs)
   hasvertex(x, vs) || error("Invalid vertex(s) $vs")
end


###
# EDGE CHECKING
###
function can_add_edge(x::AdjacencyModule, u::VertexID, v::VertexID)
   validate_vertex(x, u)
   validate_vertex(x, v)
   nothing
end

can_add_edge(x::AdjacencyModule, e::EdgeID) = can_add_edge(x, e...)

function can_add_edge(x::AdjacencyModule, es::AbstractVector{EdgeID})
   for e in es
      can_add_edge(x, e)
   end
end


###
# EDGE VALITION
###

function validate_edge(x::AdjacencyModule, u::VertexID, v::VertexID)
   hasedge(x, u, v) || error("Edge $u=>$v isn't in the graph")
   nothing
end

validate_edge(x::AdjacencyModule, e::EdgeID) = validate_edge(x, e...)

function validate_edge(x:AdjacencyModule, elist::AbstractVector{EdgeID})
   for e in elist
      validate_edge(x, e)
   end
end


################################################# IMPLEMENTATIONS #########################################################

if CAN_USE_LG
   include("adjmods/lightgraphs.jl")
end

include("adjmods/sparsematrix.jl")
