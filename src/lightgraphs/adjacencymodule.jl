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

################################################# INTERFACE IMPLEMENTATION #################################################

@inline nv(x::LightGraphsAM) = LightGraphs.nv(data(x))

@inline ne(x::LightGraphsAM) = LightGraphs.ne(data(x))

@inline Base.size(x::LightGraphsAM) = (nv(x), ne(x))

@inline vertices(x::LightGraphsAM) = LightGraphs.vertices(data(x))

@inline edges(x::LightGraphsAM) = LightGraphs.edges(data(x))

@inline hasedge(x::LightGraphsAM, u::VertexID, v::VertexID) = LightGraphs.has_edge(data(x), u, v)

@inline fadj(x::LightGraphsAM, v::VertexID) = LightGraphs.fadj(data(x), v)

@inline badj(x::LightGraphsAM, v::VertexID) = LightGraphs.badj(data(x), v)

@inline addvertex!(x::LightGraphsAM) = (LightGraphs.add_vertex!(data(x)); nothing)

# Override to prevent index from being deleted. Too expensive to relabel every vertex otherwise.
function rmvertex!(x::LightGraphsAM, v::VertexID)
   flist = x.data.fadjlist
   rlist = x.data.badjlist

   flist[v] = []
   rlist[v] = []

   for vec in flist
      filter!(x-> x!=v, vec)
   end

   for vec in rlist
      filter!(x-> x!=v, vec)
   end

   nothing
end


@inline addedge!(x::LightGraphsAM, u::VertexID, v::VertexID) = (LightGraphs.add_edge!(data(x), u, v); nothing)

@inline rmedge!(x::LightGraphsAM, u::VertexID, v::VertexID) = (LightGraphs.rem_edge!(data(x), u, v); nothing)

################################################# SUBGRAPHS #################################################################

@inline subgraph(x::LightGraphsAM, vlist::AbstractVector{VertexID}) = LightGraphsAM(LightGraphs.induced_subgraph(data(x), vlist))

function subgraph{I<:Integer}(x::LightGraphsAM, elist::Vector{Pair{I,I}})
   y = LightGraphsAM(nv(x))
   for e in elist
      addedge!(y, e...)
   end
   y
end