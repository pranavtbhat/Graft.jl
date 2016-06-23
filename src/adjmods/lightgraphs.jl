################################################# FILE DESCRIPTION #########################################################

# This file contains the LightGraphs adjacency module, as well as an implementation of the AdjacencyModule interface
 
################################################# IMPORT/EXPORT ############################################################
export
LightGraphsAM

""" An adjacency module that uses LightGraphs.DiGraph """
type LightGraphsAM <: AdjacencyModule
   data::LightGraphs.DiGraph
end

function LightGraphsAM(nv::Int=0)
   LightGraphsAM(LightGraphs.DiGraph(nv))
end

function LightGraphsAM(nv::Int, ne::Int)
   LightGraphsAM(LightGraphs.DiGraph(nv, ne))
end

################################################# ACCESSORS ################################################################

@inline data(x::LightGraphsAM) = x.data

################################################# INTERNAL IMPLEMENTATION ##################################################

Base.sizehint!(x::LightGraphsAM) = nothing

################################################# INTERFACE IMPLEMENTATION #################################################

@inline Base.deepcopy(x::LightGraphsAM) = LightGraphsAM(deepcopy(data(x)))



@inline nv(x::LightGraphsAM) = LightGraphs.nv(data(x))
@inline ne(x::LightGraphsAM) = LightGraphs.ne(data(x))
@inline Base.size(x::LightGraphsAM) = (nv(x), ne(x))



@inline vertices(x::LightGraphsAM) = LightGraphs.vertices(data(x))
@inline edges(x::LightGraphsAM) = LightGraphs.edges(data(x))


@inline hasvertex(x::LightGraphsAM, v::VertexID) = 1 <= v <= nv(x)
@inline hasedge(x::LightGraphsAM, u::VertexID, v::VertexID) = LightGraphs.has_edge(data(x), u, v)
@inline hasedge(x::LightGraphsAM, e::EdgeID) = hasedge(x, e...)
@inline fadj(x::LightGraphsAM, v::VertexID) = LightGraphs.fadj(data(x), v)
@inline badj(x::LightGraphsAM, v::VertexID) = LightGraphs.badj(data(x), v)
@inline outdegree(x::LightGraphsAM, v::VertexID) = LightGraphs.outdegree(data(x), v)
@inline indegree(x::LightGraphsAM, v::VertexID) = LightGraphs.indegree(data(x), v)


function addvertex!(x::LightGraphsAM, num::Int=1)
   D = data(x)
   for i in 1 : num
      LightGraphs.add_vertex!(D)
   end
   nothing
end



function rmvertex!(x::LightGraphsAM, v::VertexID)
   LightGraphs.rem_vertex!(data(x), v)
   nothing
end

function rmvertex!(x::LightGraphsAM, vlist::Vector{VertexID})
   for v in reverse(sort(vlist))
      rmvertex!(x, v)
   end
   nothing
end



function addedge!(x::LightGraphsAM, u::VertexID, v::VertexID)
   LightGraphs.add_edge!(data(x), u, v)
   nothing
end
@inline addedge!(x::LightGraphsAM, e::EdgeID) = addedge!(x, e...)

function addedge!(x::LightGraphsAM, elist::AbstractVector{EdgeID})
   for e in elist
      addedge!(x, e)
   end
   nothing
end



function rmedge!(x::LightGraphsAM, u::VertexID, v::VertexID)
   LightGraphs.rem_edge!(data(x), u, v)
   nothing
end
@inline rmedge!(x::LightGraphsAM, e::EdgeID) = rmedge!(x, e...)

function rmedge!(x::LightGraphsAM, elist::AbstractVector{EdgeID})
   for e in elist
      rmedge!(x, e)
   end
end

################################################# SUBGRAPHS #################################################################

@inline subgraph(x::LightGraphsAM, vlist::AbstractVector{VertexID}) = LightGraphsAM(LightGraphs.induced_subgraph(data(x), vlist))

function subgraph(x::LightGraphsAM, elist::AbstractVector{EdgeID})
   y = LightGraphsAM(nv(x))
   for e in elist
      addedge!(y, e...)
   end
   y
end