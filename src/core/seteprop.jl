################################################# FILE DESCRIPTION #########################################################
# This file contains the implementation of seteprop!

################################################# IMPORT/EXPORT ############################################################

export seteprop!

################################################# UNIT SINGLE ##############################################################

"""
Set edge properties. ParallelGraphs doesn't permit the creating of new properties in strongly typed property modules.

seteprop!(g::Graph, u::VertexID, v::VertexID, val, propname) -> Set a property for an edge u=>v
"""
function seteprop!(g::Graph, u::VertexID, v::VertexID, val, propname)
   validate_edge(g, u, v)
   seteprop!(propmod(g), u, v, val, propname)
end

""" seteprop!(g::Graph, e::EdgeID, val, propname) -> Set a property for an edge e """
seteprop!(g::Graph, e::EdgeID, val, propname) = seteprop!(g, e..., val, propname)


###
# LINEARPM
###
function seteprop!(x::LinearPM{Any,Any}, u::VertexID, v::VertexID, val, propname)
   propmote_edge_type!(x, val, propname)
   d = edata(x)[v,u]
   d[propname] = val
   edata(x)[v,u] = d
   nothing
end

function seteprop!(x::LinearPM, u::VertexID, v::VertexID, val, propname)
   propmote_edge_type!(x, val, propname)
   t = edata(x)[v,u]
   setfield!(t, symbol(propname), val)
   edata(x)[v,u] = t
   nothing
end

seteprop!(x::LinearPM, e::EdgeID, val, propname) = seteprop!(x, e..., val, propname)


###
# VECTORPM
###
function seteprop!(x::VectorPM, u::VertexID, v::VertexID, val, propname)
   propmote_edge_type!(x::VectorPM, val, propname)
   edata(x)[propname][v,u] = val
   nothing
end

################################################# MULTI SINGLE ##############################################################

""" seteprop!(g::Graph, es::AbstractVector{EdgeID}, val(s), propname) -> Set a property for e in es """
function seteprop!(g::Graph, es::AbstractVector{EdgeID}, vals::Vector, propname)
   validate_edge(g, es)
   length(es) == length(vals) || error("Trying to assign $(length(vals)) values to $(length(es)) edges")
   seteprop!(propmod(g), es, vals, propname)
end

seteprop!(g::Graph, es::AbstractVector{EdgeID}, vals::AbstractVector, propname) = seteprop!(g, es, collect(vals), propname)

seteprop!(g::Graph, es::AbstractVector{EdgeID}, val, propname) = seteprop!(g, es, fill(val, length(es)), propname)


###
# LINEARPM
###
function seteprop!(x::LinearPM, es::AbstractVector{EdgeID}, vals::Vector, propname)
   propmote_edge_type!(x, vals, propname)
   for (e,val) in zip(es,vals)
      seteprop!(x, e, val, propname)
   end
end


###
# VECTORPM
###
function seteprop!(x::VectorPM, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   propmote_edge_type!(x, vals, propname)
   sv = edata(x)[propname]
   for (i,(u,v)) in enumerate(elist)
      sv[v,u] = vals[i]
   end
end

################################################# ALL SINGLE ###############################################################

""" seteprop!(g::Graph, ::Colon, val(s), propname) -> Set a property for e in edges(g) """
function seteprop!(g::Graph, ::Colon, vals::Vector, propname)
   ne(g) == length(vals) || error("Number of edges doesn't equal number of values")
   seteprop!(propmod(g), edges(g), vals, propname)
end

seteprop!(g::Graph, ::Colon, vals::AbstractVector, propname) = seteprop!(g, :, collect(vals), propname)

seteprop!(g::Graph, ::Colon, val, propname) = seteprop!(g, :, fill(val, ne(g)), propname)


###
# LINEARPM
###
seteprop!(x::LinearPM, es::EdgeIter, vals::Vector, propname) = seteprop!(x, collect(es), vals, propname)


###
# VECTORPM
###
function seteprop!(x::VectorPM, es::EdgeIter, vals::Vector, propname)
   propmote_edge_type!(x, vals, propname)
   edata(x)[propname] = init_spmx(nv(x), collect(es), vals)
   nothing
end

################################################# UNIT DICT #################################################################

""" seteprop!(g::Graph, u::VertexID, v::VertexID, d::Dict) -> Set all properties for an edge u=>v """
function seteprop!(g::Graph, u::VertexID, v::VertexID, d::Dict)
   validate_edge(g, u, v)
   seteprop!(propmod(g), u, v, d)
end

seteprop!(g::Graph, e::EdgeID, d::Dict) = seteprop!(g, e..., d)


###
# LINEARPM
###
function seteprop!(x::LinearPM{Any,Any}, u::VertexID, v::VertexID, d::Dict)
   for (prop,val) in d
      propmote_edge_type!(x, val, prop)
   end
   setindex!(edata(x), merge!(edata(x)[v,u], d), v, u)
   nothing
end

function seteprop!(x::LinearPM, u::VertexID, v::VertexID, d::Dict)
   t = edata(x)[v,u]
   for (prop,val) in d
      propmote_edge_type!(x, val, prop)
      setfield!(t, symbol(prop), val)
   end
   edata(x)[v,u] = t
   nothing
end

seteprop!(x::LinearPM, e::EdgeID, d::Dict) = seteprop!(x, e..., d)


###
# VECTORPM
###
function seteprop!(x::VectorPM, u::VertexID, v::VertexID, d::Dict)
   for (prop,val) in d
      seteprop!(x, u, v, val, prop)
   end
end

seteprop!(x::VectorPM, e::EdgeID, d::Dict) = seteprop!(x, e..., d)


################################################# MULTI DICT #################################################################

""" seteprop!(g::Graph, es::AbstractVector{EdgeID}, ds::Vector) -> Set all properties for e in es """
function seteprop!(g::Graph, es::AbstractVector{EdgeID}, ds::Vector)
   validate_edge(g, es)
   length(es) == length(ds) || error("Number of edges doesn't equal number of values")
   seteprop!(propmod(g), es, ds)
end


###
# PROPERTY MODULE
###
function seteprop!(x::PropertyModule, elist::AbstractVector{EdgeID}, dlist::Vector)
   for (e,d) in zip(elist,dlist)
      seteprop!(x, e, d)
   end
end


################################################# ALL DICT ###################################################################

""" seteprop!(g::Graph, es::AbstractVector{EdgeID}, ds::Vector) -> Set all properties for e in edges(g) """
seteprop!(g::Graph, ::Colon, ds::Vector) = seteprop!(propmod(g), collect(edges(g)), ds)

################################################# MULTI FUNCTION ##############################################################

""" seteprop!(g::Graph, elist::AbstractVector{EdgeID}, f::Function, propname) -> Map onto a property for e in es """
function seteprop!(g::Graph, elist::AbstractVector{EdgeID}, f::Function, propname)
   validate_edge(g, elist)
   seteprop!(propmod(g), elist, f, propname)
end


###
# LINEARPM
###
function seteprop!(x::LinearPM, elist::AbstractVector{EdgeID}, f::Function, propname)
   for e in elist
      seteprop!(x, e, f(e...), propname)
   end
end


###
# VECTORPM
###
function seteprop!(x::VectorPM, elist::AbstractVector{EdgeID}, f::Function, propname)
   seteprop!(x, elist, [f(u,v) for (u,v) in elist], propname)
end

################################################# ALL FUNCTION ##############################################################

""" seteprop!(g::Graph, ::Colon, f::Function, propname) -> Map onto a property for all edges """
function seteprop!(g::Graph, ::Colon, f::Function, propname)
   seteprop!(propmod(g), edges(g), f, propname)
end

###
# LINEARPM
###
seteprop!(x::LinearPM, es::EdgeIter, f::Function, propname) = seteprop!(x, collect(es), f, propname)


###
# VECTORPM
###
function seteprop!(x::VectorPM, es::EdgeIter, f::Function, propname)
   elist = collect(es)
   vals = [f(u,v) for (u,v) in elist]
   propmote_edge_type!(x, vals, propname)
   edata(x)[propname] = init_spmx(nv(x), elist, vals)
   nothing
end
