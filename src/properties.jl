export vprops, eprops

###
# Each vertex/edge can have properties assigned to it. A property is a key-value pair. The key must be a AbstractString(?).
# This file contains mappings between the keys and their indices in the sparse table. 
###

""" Translates Vertex/Edge property names to indexes in the sparse table and back """
type PropertyMap
   nvprop::PropID                                        # Number of vertex properties
   neprop::PropID                                        # Number of edge properties
   vprop_fmap::Dict{AbstractString, PropID}               # Vertex Property Forward Map
   vprop_rmap::Vector{AbstractString}                       # Vertex Property Reverse Map
   eprop_fmap::Dict{AbstractString, PropID}                 # Edge Property Forward Map
   eprop_rmap::Vector{AbstractString}                       # Edge Property Reverse Map
end

function PropertyMap()
   vprop_fmap = Dict{AbstractString, PropID}()
   vprop_rmap = AbstractString[]
   eprop_fmap = Dict{AbstractString, PropID}("id" => 1)
   eprop_rmap = AbstractString["id"]

   PropertyMap(0, 1, vprop_fmap, vprop_rmap, eprop_fmap, eprop_rmap)
end

###
# LIST PROPERTIES
###

""" List all vertex properties """
vrops(pmap::PropertyMap) = vprop_rmap

""" List all edge properties """
eprops(pmap::PropertyMap) = eprop_rmap

###
# CREATE AND RETRIEVE MAPPINGS
###
""" Fetch the sparse table index for the given vertex property name """
function vproptoi(x::PropertyMap, prop::AbstractString)
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

""" Fetch the sparse table index for the give """
function eproptoi(x::PropertyMap, prop::AbstractString)
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