################################################# FILE DESCRIPTION #########################################################
# This file contains the implementation of setvprop!

################################################# IMPORT/EXPORT ############################################################

export setvprop!

################################################# UNIT SINGLE ##############################################################

"""
Set vertex properties. ParallelGraphs doesn't permit the creating of new properties in strongly typed property modules.

setvprop!(g::Graph, v::VertexID, val, propname) -> Set a property for a vertex
"""
function setvprop!(g::Graph, v::VertexID, val, propname)
   validate_vertex(g, v)
   setvprop!(propmod(g), v, val, propname)
end


###
# LINEARPM
###
function setvprop!(x::LinearPM, v::VertexID, val, propname)
   propmote_vertex_type!(x, val, propname)
   setfield!(vdata(x)[v], symbol(propname), val)
end

function setvprop!(x::LinearPM{Any,Any}, v::VertexID, val, propname)
   propmote_vertex_type!(x, val, propname)
   setindex!(vdata(x)[v], val, propname)
end

###
# VECTORPM
###
function setvprop!(x::VectorPM, v::VertexID, val, propname)
   propmote_vertex_type!(x, val, propname)
   vdata(x)[propname][v] = val
   nothing
end

################################################# MULTI SINGLE ##############################################################

""" setvprop!(g::Graph, vs::AbstractVector{VertexID}, val(s), propname) -> Set a property for v in vs """
function setvprop!(g::Graph, vs::AbstractVector{VertexID}, vals::Vector, propname)
   validate_vertex(g, vs)
   length(vs) == length(vals) || error("Trying to assign $(length(vals)) values to $(length(vs)) vertices")
   setvprop!(propmod(g), vs, vals, propname)
end

function setvprop!(g::Graph, vs::AbstractVector{VertexID}, vals::AbstractVector, propname)
   setvprop!(propmod(g), vs, collect(vals), propname)
end

function setvprop!(g::Graph, vs::AbstractVector{VertexID}, val, propname)
   setvprop!(propmod(g), vs, fill(val, length(vs)), propname)
end


###
# LINEARPM
###
function setvprop!(x::LinearPM{Any,Any}, vs::AbstractVector{VertexID}, vals::Vector, propname)
   propmote_vertex_type!(x, vals, propname)
   for (v,val) in zip(vs, vals)
      setindex!(vdata(x)[v], val, propname)
   end
end

function setvprop!(x::LinearPM, vs::AbstractVector{VertexID}, vals::Vector, propname)
   propmote_vertex_type!(x, vals, propname)
   sym = symbol(propname)
   for (v,val) in zip(vs, vals)
      setfield!(vdata(x)[v], sym, val)
   end
end


###
# VECTORPM
###
function setvprop!(x::VectorPM, vs::AbstractVector{VertexID}, vals::Vector, propname)
   propmote_vertex_type!(x, vals, propname)
   vdata(x)[propname][vs] = vals
   nothing
end

################################################# ALL SINGLE ###############################################################

""" setvprop!(g::Graph, ::Colon, val(s), propname) -> Set a property for v in vertices(g) """
function setvprop!(g::Graph, ::Colon, vals::Vector, propname)
   nv(g) == length(vals) || error("Trying to assign $(length(vals)) values to $(nv(g)) vertices")
   setvprop!(propmod(g), :, vals, propname)
end

setvprop!(g::Graph, ::Colon, vals::AbstractVector, propname) = setvprop!(g, :, collect(vals), propname)
setvprop!(g::Graph, ::Colon, val, propname) = setvprop!(g, :, fill(val, nv(g)), propname)


###
# LINEARPM
###
setvprop!(x::LinearPM, ::Colon, vals::Vector, propname) = setvprop!(x, 1 : length(vdata(x)), vals, propname)


###
# VECTORPM
###
function setvprop!(x::VectorPM, ::Colon, vals::Vector, propname)
   propmote_vertex_type!(x, vals, propname)
   vdata(x)[propname] = vals
   nothing
end

################################################# MULTI FUNCTION ##############################################################

""" setvprop!(g::Graph, vs::AbstractVector{VertexID}, f::Function, propname) -> Map onto a property for v in vs """
function setvprop!(g::Graph, vs::AbstractVector{VertexID}, f::Function, propname)
   validate_vertex(g, vs)
   setvprop!(propmod(g), vs, f, propname)
end


###
# LINEARPM
###
function setvprop!(x::LinearPM, vs::AbstractVector{VertexID}, f::Function, propname)
   for v in vs
      setvprop!(x, v, f(v), propname)
   end
end


###
# VECTORPM
###
function setvprop!(x::VectorPM, vs::AbstractVector{VertexID}, f::Function, propname)
   vals = [f(v) for v in vs]
   setvprop!(x, vs, vals, propname)
end

################################################# ALL FUNCTION #############################################################

""" setvprop!(g::Graph, ::Colon, f::Function, propname) -> Map onto a property for v in vertices(g) """
setvprop!(g::Graph, ::Colon, f::Function, propname) = setvprop!(propmod(g), :, f, propname)


###
# LINEARPM
###
setvprop!(x::LinearPM, ::Colon, f::Function, propname) = setvprop!(x, 1 : length(vdata(x)), f, propname)

###
# VECTORPM
###
function setvprop!(x::VectorPM, ::Colon, f::Function, propname)
   vals = [f(v) for v in 1 : nv(x)]
   setvprop!(x, :, vals, propname)
end

################################################# SINGLE DICT ################################################################

""" setvprop!(g::Graph, v::VertexID, d::Dict) -> Set all properties for a vertex v """
function setvprop!(g::Graph, v::VertexID, d::Dict)
   validate_vertex(g, v)
   setvprop!(propmod(g), v, d)
end


function setvprop!(x::PropertyModule, v::VertexID, d::Dict)
   for (key,val) in d
      setvprop!(x, v, val, key)
   end
end

################################################# MULTI DICT #################################################################

""" setvprop!(g::Graph, vs::AbstractVector{VertexID}, ds::Vector{Dict}) -> Set all properties for v in vs """
function setvprop!(g::Graph, vs::AbstractVector{VertexID}, ds::Vector)
   length(vs) == length(ds) || error("Trying to assign $(length(ds)) values to $(length(vs)) vertices")
   setvprop!(propmod(g), vs, ds)
end

###
# PROPERTYMODULE
###
function setvprop!(x::PropertyModule, vlist::AbstractVector{VertexID}, dlist::Vector)
   for (v,d) in zip(vlist,dlist)
      setvprop!(x, v, d)
   end
end

################################################# ALL DICT ###################################################################

""" setvprop!(g::Graph, ::Colon, ds::AbstractVector{Dict}) -> Set all properties for v in vertices(g) """
function setvprop!(g::Graph, ::Colon, ds::Vector)
   nv(g) == length(ds) || error("Trying to assign $(length(vals)) values to $(nv(g)) vertices")
   setvprop!(propmod(g), vertices(g), ds)
end
