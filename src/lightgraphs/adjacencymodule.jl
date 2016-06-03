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
end

################################################# ACCESSORS ################################################################

@inline data(x::LightGraphsAM) = x.data

################################################# INTERFACE IMPLEMENTATION #################################################

@inline nv(x::LightGraphsAM) = LightGraphs.nv(data(x))

@inline ne(x::LightGraphsAM) = LightGraphs.ne(data(x))

@inline Base.size(x::LightGraphsAM) = (nv(x), ne(x))

@inline fadj(x::LightGraphsAM, v::VertexID) = copy(LightGraphs.fadj(data(x), v))

@inline badj(x::LightGraphsAM, v::VertexID) = copy(LightGraphs.badj(data(x), v))

@inline addvertex!(x::LightGraphsAM) = (LightGraphs.add_vertex!(data(x)); nothing)

@inline rmvertex!(x::LightGraphsAM, v::VertexID) = (LightGraphs.rem_vertex!(data(x), v); nothing)

@inline addedge!(x::LightGraphsAM, u::VertexID, v::VertexID) = (LightGraphs.add_edge!(data(x), u, v); nothing)

@inline rmedge!(x::LightGraphsAM, u::VertexID, v::VertexID) = (LightGraphs.rem_edge!(data(x), u, v); nothing)