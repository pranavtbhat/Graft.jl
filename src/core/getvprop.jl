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
   validate_vertex(g, vs)
   getvprop(propmod(g), vs)
end


###
# LINEARPM
###
function getvprop(x::LinearPM{Any,Any}, v::VertexID)
   data = vdata(x)[v]
   [get(data, prop, zero(typ)) for (prop,typ) in vprops(x)]
end

function getvprop(x::LinearPM, v::VertexID)
   data = vdata(x)[v]
   [getfield(data, field) for field in keys(vprops(x))]
end


###
# VECTORPM
###
getvprop(x::VectorPM, v::VertexID) = [prop => arr[v] for (prop,arr) in vdata(x)]

################################################# MUTLI DICT ################################################################

""" getvprop(g::Graph, vs::AbstractVector{VertexID}) -> A list of dictionaries for v in vs """
function getvprop(g::Graph, vs::AbstractVector{VertexID})
   validate_vertex(g, vs)
   getvprop(propmod(g), vs)
end

###
# LINEARPM
###
getvprop(x::LinearPM, vlist::AbstractVector{VertexID}) = [getvprop(x, v) for v in vlist]


###
# VECTORPM
###
getvprop(x::VectorPM, vlist::AbstractVector{VertexID}) = [getvprop(x, v) for v in vlist]

################################################# ALL DICT ##################################################################

""" getvprop(g::Graph, ::Colon) -> A list of dictionaries for v in vertices(g) """
getvprop(g::Graph, ::Colon) = getvprop(propmod(g), vertices(g))


################################################# UNIT SINGLE ###############################################################

""" getvprop(g::Graph, v::VertexID, property) -> Fetch the value of a property for vertex v (or its default value) """
function getvprop(g::Graph, v::VertexID, propname)
   validate_vertex(g, vs)
   validate_vertex_property(g, prop)
   getvprop(propmod(g), vs, prop)
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
   validate_vertex_property(g, prop)
   getvprop(propmod(g), vs, prop)
end


###
# LINEARPM
###
getvprop(x::LinearPM{Any,Any}, vs::AbstractVector{VertexID}, propname) = [getvprop(x, v, propname) for v in vs]

function getvprop(x::LinearPM, vs::AbstractVector{VertexID}, propname)
   sym = Symbol(propame)
   [getvprop(x, v, sym) for v in vs]
end


###
# VECTORPM
###
getvprop(x::VectorPM, vs::AbstractVector{VertexID}, propname) = vdata(x)[property][vs]

################################################# All SINGLE ##################################################################

""" getvprop(g::Graph, ::Colon, property) -> Fetch the value of a property for v in vertices(g) """
getvprop(g::Graph, ::Colon, propname) = getvprop(propmod(g), :, propname)
