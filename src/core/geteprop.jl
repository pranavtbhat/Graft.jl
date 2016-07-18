################################################# FILE DESCRIPTION #########################################################

# This file contains the implementation for geteprop.

################################################# IMPORT/EXPORT ############################################################

export geteprop

################################################# UNIT DICT ################################################################

"""
Retrieve edge properties. ParallelGraphs presents a sparse storage interface. If an edge doesn't have a property attached,
a default value is returned.

geteprop(g::Graph, u::VertexID, v::VertexID) -> Dictionary containing edge e's properties
"""
function geteprop(g::Graph, u::VertexID, v::VertexID)
   validate_edge(g, u, v)
   geteprop(propmod(g), u, v)
end

""" geteprop(g::Graph, e::EdgeID) -> Dictionary containing edge e's properties """
geteprop(g::Graph, e::EdgeID) = geteprop(g, e...)


###
# LINEARPM
###
function geteprop(x::LinearPM{Any,Any}, u::VertexID, v::VertexID)
   data = edata(x)[v,u]
   [prop => get(data, prop, zero(typ)) for (prop,typ) in eprops(x)]
end

function geteprop{V,E}(x::LinearPM{V,E}, u::VertexID, v::VertexID)
   data = edata(x)[v,u]
   [string(field) => getfield(data, field) for field in fieldnames(E)]
end

geteprop(x::LinearPM, e::EdgeID) = geteprop(x, e...)


###
# VECTORPM
###
geteprop(x::VectorPM, u::VertexID, v::VertexID) = [prop => arr[v,u] for (prop,arr) in edata(x)]
geteprop(x::VectorPM, e::EdgeID) = geteprop(x, e...)

################################################# MUTLI DICT ################################################################

""" geteprop(g::Graph, es::AbstractVector{EdgeID}) -> A list of dictionaries for e in es """
function geteprop(g::Graph, es::AbstractVector{EdgeID})
   validate_edge(g, es)
   geteprop(propmod(g), es)
end

###
# LINEARPM
###
geteprop(x::LinearPM, elist::AbstractVector{EdgeID}) = [geteprop(x, e) for e in elist]


###
# VECTORPM
###
function geteprop(x::VectorPM, elist::AbstractVector{EdgeID})
   dlist = [Dict() for i in 1:length(elist)]
   for (key,arr) in edata(x)
      vals = geteprop(x, elist, key)
      for (i,d) in enumerate(dlist)
         d[key] = vals[i]
      end
   end
   dlist
end

################################################# ALL DICT ##################################################################

""" geteprop(g::Graph, ::Colon) -> A list of dictionaries for e in edges(g) """
geteprop(g::Graph, ::Colon) = geteprop(propmod(g), collect(edges(g)))


################################################# UNIT SINGLE ###############################################################

""" geteprop(g::Graph, u::VertexID, v::VertexID, property) -> Fetch the value of a property for edge u=>v (or its default value) """
function geteprop(g::Graph, u::VertexID, v::VertexID, property)
   validate_edge(g, u, v)
   validate_edge_property(g, property)
   geteprop(propmod(g), u, v, property)
end

""" geteprop(g::Graph, e::EdgeID, property) -> Fetch the value of a property for edge e """
geteprop(g::Graph, e::EdgeID, property) = geteprop(g, e..., property)


###
# LINEARPM
###
geteprop(x::LinearPM{Any,Any}, u::VertexID, v::VertexID, propname) = get(edata(x)[v,u], propname, eprops(x)[propname] |> zero)
geteprop(x::LinearPM, u::VertexID, v::VertexID, propname) = getfield(edata(x)[v,u], symbol(propname))
geteprop(x::LinearPM, e::EdgeID, propname) = geteprop(x, e..., propname)


###
# VECTORPM
###
geteprop(x::VectorPM, u::VertexID, v::VertexID, propname) = edata(x)[propname][v,u]

################################################# MULTI SINGLE ###############################################################

""" geteprop(g::Graph, es::AbstractVector{EdgeID}, property) -> Fetch the value of a property for e in es """
function geteprop(g::Graph, es::AbstractVector{EdgeID}, property)
   validate_edge(g, es)
   validate_edge_property(g, property)
   geteprop(propmod(g), es, property)
end


###
# LINEARPM
###
geteprop(x::LinearPM{Any,Any}, es::AbstractVector{EdgeID}, propname) = [geteprop(x, e, propname) for e in es]

function geteprop(x::LinearPM, es::AbstractVector{EdgeID}, propname)
   sym = Symbol(propname)
   [geteprop(x, e, sym) for e in es]
end


###
# VECTORPM
###
function geteprop(x::VectorPM, elist::AbstractVector{EdgeID}, propname)
   sv = edata(x)[propname]
   [sv[v,u] for (u,v) in elist]
end

################################################# All SINGLE ##################################################################

""" geteprop(g::Graph, ::Colon, property) -> Fetch the value of a property for e in edges(g) """
function geteprop(g::Graph, ::Colon, propname)
   validate_edge_property(g, propname)
   geteprop(propmod(g), collect(edges(g)), propname)
end

###
# VECTORPM
###
function geteprop(x::VectorPM, es::EdgeIter, propname)
   sv = edata(x)[propname]
   sv.nzval
end
