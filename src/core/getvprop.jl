################################################# FILE DESCRIPTION #########################################################

# This file contains the implementation for getvprop.

################################################# IMPORT/EXPORT ############################################################

export getvprop

################################################# UNIT DICT ################################################################

"""
Retrieve vertex properties. ParallelGraphs presents a sparse storage interface. If a vertex doesn't have a property attached,
a default value is returned.

getvprop(g::Graph, v::VertexID) -> Dictionary containing vertex v's properties.
"""
function getvprop(g::Graph, v::VertexID)
   validate_vertex(g, v)
   getvprop(propmod(g), v)
end


###
# LINEARPM
###
function getvprop(x::LinearPM{Any,Any}, v::VertexID)
   data = vdata(x)[v]
   Dict(prop => get(data, prop, zero(typ)) for (prop,typ) in vprops(x))
end

function getvprop{V,E}(x::LinearPM{V,E}, v::VertexID)
   data = vdata(x)[v]
   Dict(string(field) => getfield(data, field) for field in fieldnames(V))
end


###
# VECTORPM
###
getvprop(x::VectorPM, v::VertexID) = Dict(prop => arr[v] for (prop,arr) in vdata(x))

################################################# UNIT SINGLE ###############################################################

""" getvprop(g::Graph, v::VertexID, property) -> Fetch the value of a property for vertex v (or its default value) """
function getvprop(g::Graph, v::VertexID, propname)
   validate_vertex(g, v)
   validate_vertex_property(g, propname)
   getvprop(propmod(g), v, propname)
end


###
# LINEARPM
###
getvprop(x::LinearPM{Any,Any}, v::VertexID, propname) = get(vdata(x)[v], propname, vprops(x)[propname] |> zero)
getvprop(x::LinearPM, v::VertexID, propname) = getfield(vdata(x)[v], Symbol(propname))


###
# VECTORPM
###
getvprop(x::VectorPM, v::VertexID, propname) = vdata(x)[propname][v]


################################################# MULTI SINGLE ###############################################################

""" getvprop(g::Graph, vs::AbstractVector{VertexID}, property) -> Fetch the value of a property for v in vs """
function getvprop(g::Graph, vs::AbstractVector{VertexID}, propname)
   validate_vertex(g, vs)
   validate_vertex_property(g, propname)
   getvprop(propmod(g), vs, propname)
end


###
# LINEARPM
###
getvprop(x::LinearPM{Any,Any}, vs::AbstractVector{VertexID}, propname) = [getvprop(x, v, propname) for v in vs]

function getvprop(x::LinearPM, vs::AbstractVector{VertexID}, propname)
   sym = Symbol(propname)
   [getvprop(x, v, sym) for v in vs]
end


###
# VECTORPM
###
getvprop(x::VectorPM, vs::AbstractVector{VertexID}, propname) = vdata(x)[propname][vs]

################################################# All SINGLE ##################################################################

""" getvprop(g::Graph, ::Colon, property) -> Fetch the value of a property for v in vertices(g) """
getvprop(g::Graph, ::Colon, propname) = getvprop(propmod(g), vertices(g), propname)
