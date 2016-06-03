################################################# FILE DESCRIPTION #########################################################

# This file contains the SimpleGraph type which uses a LightGraphsAM and a DictPM.
 
################################################# IMPORT/EXPORT ############################################################
export
SimpleGraph

""" A non-customizable graph that allows for String property names only """
type SimpleGraph <: Graph
   adjmod::LightGraphsAM
   propmod::DictPM

   function SimpleGraph(nv=0)
      self = new()
      self.adjmod = LightGraphsAM(nv)
      self.propmod = DictPM{ASCIIString, Any}()
      self
   end
end


################################################# INTERFACE IMPLEMENTATION #################################################

@inline adjmod(g::SimpleGraph) = g.adjmod

@inline propmod(g::SimpleGraph) = g.propmod


