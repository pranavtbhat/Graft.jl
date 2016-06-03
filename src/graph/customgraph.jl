################################################# FILE DESCRIPTION #########################################################

# This file contains the CustomGraph graph type that provides flexibility in choosing both the AdjacencyModule and the 
# PropertyModule
 
################################################# IMPORT/EXPORT ############################################################
export
CustomGraph

""" A customizable graph """
type CustomGraph{AM,PM} <: Graph
   adjmod::AM
   propmod::PM

   function CustomGraph(nv=0)
      self = new()
      self.adjmod = AM(nv)
      self.propmod = PM()
      self
   end
end


################################################# INTERFACE IMPLEMENTATION #################################################

@inline adjmod(g::CustomGraph) = g.adjmod

@inline propmod(g::CustomGraph) = g.propmod


