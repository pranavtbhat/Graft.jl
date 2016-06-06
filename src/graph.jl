################################################# FILE DESCRIPTION #########################################################

# This file contains the core graph definitions. ParallelGraphs provides a Graph interface that all 
# graph types must adhere to. 
# Every graph MUST have:
# 1. An adjacency module that adheres to the AdjacencyModule interface.
# 2. A property module that adheres to the PropertyModule interface. 
# Additionally every graph must also adhere to the graph interface detailed below.

################################################# IMPORT/EXPORT ############################################################
export 
# Types
Graph, SimpleGraph,
# Constants
Adjacency_Interface_Methods, Property_Interface_Methods

type Graph{AM,PM}
   adjmod::AM
   propmod::PM

   function Graph(nv::Int=0)
      self = new()
      self.adjmod = AM(nv)
      self.propmod = PM()
      self
   end
end

################################################# GRAPH INTERFACE ##########################################################

""" Retrieve a graph's adjacency module """
@inline adjmod(x::Graph) = x.adjmod

""" Retrieve a graph's property module """
@inline propmod(x::Graph) = x.propmod

################################################# METHOD REDIRECTION #######################################################

@redirect nv(g::Graph) adjmod
@redirect nv(g::Graph) adjmod
@redirect ne(g::Graph) adjmod
@redirect size(g::Graph) adjmod
@redirect fadj(g::Graph, v::VertexID) adjmod
@redirect badj(g::Graph, v::VertexID) adjmod
@redirect addvertex!(g::Graph) adjmod
@redirect rmvertex!(g::Graph, v::VertexID) adjmod
@redirect addedge!(g::Graph, u::VertexID ,v::VertexID) adjmod
@redirect rmedge!(g::Graph, u::VertexID, v::VertexID) adjmod

@redirect listvprops(g::Graph) propmod
@redirect listeprops(g::Graph) propmod
@redirect getvprop(g::Graph, v::VertexID) propmod
@redirect getvprop{K}(g::Graph, v::VertexID, propname::K) propmod
@redirect geteprop(g::Graph, u::VertexID, v::VertexID) propmod
@redirect geteprop{K}(g::Graph, u::VertexID, v::VertexID, propname::K) propmod
@redirect setvprop!(g::Graph, v::VertexID, props::Dict) propmod
@redirect setvprop!{K,V}(g::Graph, v::VertexID, propname::K, val::V) propmod
@redirect seteprop!(g::Graph, u::VertexID, v::VertexID, props::Dict) propmod
@redirect seteprop!{K,V}(g::Graph, u::VertexID, v::VertexID, propname::K, val::V) propmod

################################################# TYPE ALIASES ###############################################################

typealias SimpleGraph Graph{LightGraphsAM,DictPM{ASCIIString,Any}}