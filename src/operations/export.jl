################################################# FILE DESCRIPTION #########################################################

# This file contains methods to export data to LightGraphs.jl

################################################# IMPORT/EXPORT ############################################################

export export_adjacency, export_vertex_property, export_edge_property

################################################# HELPERS ##################################################################

process_array(x::Vector) = x

process_array(x::DataArrays.DataArray) = x.data
###
# TODO: Figure out what to do with nonstandard arrays like NullableArrays or DataArrays.
###

export_adjacency(g::Graph) = copy(indxs(g))

function export_vertex_property(g::Graph, vprop::Symbol)
   process_array(getvprop(g, :, vprop))
end

function export_edge_property(g::Graph, eprop::Symbol)
   eit = edges(g)
   arr = process_array(geteprop(g, :, eprop))
   sparse(eit.vs, eit.us, arr)
end
