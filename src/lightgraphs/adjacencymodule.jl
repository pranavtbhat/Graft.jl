################################################# FILE DESCRIPTION #########################################################

# This file contains the LightGraphs adjacency module, as well as an implementation of the AdjacencyModule interface
 
################################################# IMPORT/EXPORT ############################################################
export
LightGraphsAM

""" An adjacency module that uses LightGraphs.DiGraph """
type LightGraphsAM <: AdjacencyModule
   data::LightGraphs.DiGraph

   function LightGraphsAM(nv=0)
      self = new()
      self.data = LightGraphs.DiGraph(nv)
      self
   end

   function LightGraphsAM(x::LightGraphs.DiGraph)
      self = new()
      self.data = x
      self
   end
end

################################################# GENERATORS ###############################################################

function LightGraphsAM(nv::Int, ne::Int)
   LightGraphsAM(LightGraphs.DiGraph(nv, ne))
end

################################################# ACCESSORS ################################################################

@inline data(x::LightGraphsAM) = x.data

################################################# INTERFACE IMPLEMENTATION #################################################

@inline nv(g::Graph{LightGraphsAM}) = LightGraphs.nv(data(adjmod(g)))

@inline ne(g::Graph{LightGraphsAM}) = LightGraphs.ne(data(adjmod(g)))

@inline Base.size(g::Graph{LightGraphsAM}) = (nv(g), ne(g))

@inline fadj(g::Graph{LightGraphsAM}, v::VertexID) = LightGraphs.fadj(data(adjmod(g)), v)

@inline badj(g::Graph{LightGraphsAM}, v::VertexID) = LightGraphs.badj(data(adjmod(g)), v)

@inline addvertex!(g::Graph{LightGraphsAM}) = (LightGraphs.add_vertex!(data(adjmod(g))); nothing)

@inline rmvertex!(g::Graph{LightGraphsAM}, v::VertexID) = (LightGraphs.rem_vertex!(data(adjmod(g)), v); nothing)

@inline addedge!(g::Graph{LightGraphsAM}, u::VertexID, v::VertexID) = (LightGraphs.add_edge!(data(adjmod(g)), u, v); nothing)

@inline rmedge!(g::Graph{LightGraphsAM}, u::VertexID, v::VertexID) = (LightGraphs.rem_edge!(data(adjmod(g)), u, v); nothing)

################################################# SUBGRAPHS #################################################################

@inline subgraph(x::LightGraphsAM, vlist::AbstractVector{VertexID}) = LightGraphsAM(LightGraphs.induced_subgraph(data(x), vlist))