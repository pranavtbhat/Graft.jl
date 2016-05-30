################################################# FILE DESCRIPTION #########################################################

# ParallelGraphs allows the assignment of properties (key-value pairs) the the edges and vertices in a graph. The key is 
# usually a string, and therefore keys must be mapped on to integers, before they can be used to index Sparse arrays. This 
# file contains the Property Map type and related definitions. The forward maps are dictionaries that convert keys into 
# indices, while the reverse maps are vectors and convert indices into keys. Both maps are kept since the number of 
# properies is usally low, and the key/index resolution is a bottleneck for most queries.
#
# Vertices need not have a property attached to them. However every edge has an id property. 

################################################# IMPORT/EXPORT ############################################################
export 
# Getters/Setters
vprops, eprops,
# Mappings
vproptoi, eproptoi, itovprop, itoeprop

################################################# PROPERTYMAP ##############################################################

""" Translates Vertex/Edge property names to indexes in the sparse table and back """
type PropertyMap
   nvprop::PropID                                        # Number of vertex properties
   neprop::PropID                                        # Number of edge properties
   vprop_fmap::Dict{PropName, PropID}                    # Vertex Property Forward Map
   vprop_rmap::Vector{PropName}                          # Vertex Property Reverse Map
   eprop_fmap::Dict{PropName, PropID}                    # Edge Property Forward Map
   eprop_rmap::Vector{PropName}                          # Edge Property Reverse Map
end

function PropertyMap()
   vprop_fmap = Dict{PropName, PropID}()
   vprop_rmap = PropName[]
   eprop_fmap = Dict{PropName, PropID}("id" => 1)
   eprop_rmap = PropName["id"]

   PropertyMap(0, 1, vprop_fmap, vprop_rmap, eprop_fmap, eprop_rmap)
end

################################################# GETTERS/SETTERS ##########################################################

""" List all vertex properties """
vprops(pmap::PropertyMap) = pmap.vprop_rmap

""" List all edge properties """
eprops(pmap::PropertyMap) = pmap.eprop_rmap

################################################# MAPPING ###################################################################

""" Fetch the sparse table index for the given vertex property name """
function vproptoi(x::PropertyMap, prop::PropName)
   if !haskey(x.vprop_fmap, prop)
      # Create a new mapping
      x.nvprop += 1
      x.vprop_fmap[prop] = x.nvprop
      push!(x.vprop_rmap, prop)
      x.nvprop
   else
      x.vprop_fmap[prop]
   end
end

""" Fetch the sparse table index for the given edge property name """
function eproptoi(x::PropertyMap, prop::PropName)
   if !haskey(x.eprop_fmap, prop)
      # Create a new mapping
      x.neprop += 1
      x.eprop_fmap[prop] = x.neprop
      push!(x.eprop_rmap, prop)
      x.neprop
   else
      x.eprop_fmap[prop]
   end
end

""" Fetch the name of the vertex property indicated by a sparse table index """
itovprop(x::PropertyMap, i::PropID) = x.vprop_rmap[i]

""" Fetch the name of the edge property indicated by a sparse table index """
itoeprop(x::PropertyMap, i::PropID) = x.eprop_rmap[i]