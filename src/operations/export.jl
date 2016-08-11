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

"""
This method provides compatibilty with LightGraphs.jl, by returning the graph's adjacency
matrix.

```julia
import LightGraphs
g = Graph(10^5, 10^6)

# Construct a LightGraphs DiGraph from the exported adjacency matrix
LightGraphs.DiGraph(export_adjacency(g))
```
"""
export_adjacency(g::Graph) = copy(indxs(g))

"""
This method provides compatibilty with LightGraphs.jl, by returning an array containing
all values for a vertex property
"""
function export_vertex_property(g::Graph, vprop::Symbol)
   process_array(getvprop(g, :, vprop))
end

"""
This method provides compatibilty with LightGraphs.jl, by returning a SparseMatrixCSC
containing all values for an edge property
"""
function export_edge_property(g::Graph, eprop::Symbol)
   eit = edges(g)
   arr = process_array(geteprop(g, :, eprop))
   sparse(eit.vs, eit.us, arr, nv(g), nv(g))
end
