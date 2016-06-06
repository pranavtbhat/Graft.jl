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