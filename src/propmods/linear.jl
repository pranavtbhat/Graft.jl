################################################# FILE DESCRIPTION #########################################################

# This file contains a Linear implemenation of the PropertyModule interface. The module uses dictionaries or user
# defined types depending on the constructor used.

################################################# IMPORT/EXPORT ############################################################

export LinearPM

type LinearPM{V,E} <: PropertyModule{V,E}
   vprops::Set{Any}
   eprops::Set{Any}
   vdata::Vector
   edata::SparseMatrixCSC

   function LinearPM(vprops::Set, eprops::Set, vdata::AbstractVector, edata::SparseMatrixCSC)
      new(vprops, eprops, vdata, edata)
   end

   function LinearPM(nv::Int=1)
      self = new()
      self.vprops = Set{Any}(map(string, fieldnames(V)))
      self.eprops = Set{Any}(map(string, fieldnames(E)))

      if V == Any
         self.vdata = [Dict() for i in 1:nv]
      else
         self.vdata = [zero(V) for i in 1:nv]
      end

      if E == Any
         self.edata = spzeros(Dict, nv, nv)
      else
         self.edata = spzeros(E, nv, nv)
      end

      self
   end
end

function LinearPM(nv::Int=0)
   LinearPM{Any,Any}(nv)
end

@inline vprops(x::LinearPM) = x.vprops
@inline eprops(x::LinearPM) = x.eprops
@inline vdata(x::LinearPM) = x.vdata
@inline edata(x::LinearPM) = x.edata

################################################# MISCELLANIOUS #############################################################

function Base.deepcopy(x::LinearPM)
   LinearPM(deepcopy(vprops(x)), deepcopy(eprops(x)), deepcopy(vdata(x)), deepcopy(edata(x)))
end

@inline function check_vprop(x::LinearPM, propname)
   in(propname, vprops(x)) || error("Vertex has no property: $propname")
end

@inline function check_eprop(x::LinearPM, propname)
   in(propname, eprops(x)) || error("Edge has no property: $propname")
end

################################################# MUTATION ##################################################################

# Add nv vertices
function addvertex!(x::LinearPM, nv::Int=1)
   append!(vdata(x), zeros(eltype(vdata(x)), nv))
   x.edata = grow(edata(x), nv)
   nothing
end


# Remove vertex(s)
function rmvertex!(x::LinearPM, v)
   deleteat!(vdata(x), v)
   x.edata = remove_cols(edata(x), v)
   nothing
end


# Add edge(s)
addedge!(x::LinearPM, u::VertexID, v::VertexID) = nothing
addedge!(x::LinearPM, e::EdgeID) = nothing
addedge!(x::LinearPM, es::AbstractVector{EdgeID}) = nothing


# Remove edges(s)
function rmedge!(x::LinearPM, u::VertexID, v::VertexID)
   delete_entry!(edata(x), u, v)
   nothing
end
@inline rmedge!(x::LinearPM, e::EdgeID) = rmedge!(x, e...)

function rmedge!(x::LinearPM, es::AbstractVector{EdgeID})
   for (u,v) in es
      delete_entry!(edata(x), u, v)
   end
end


################################################# PROPERTIES ##############################################################

hasvprop(x::LinearPM, prop) = in(prop, vprops(x))
haseprop(x::LinearPM, prop) = in(prop, eprops(x))


listvprops(x::LinearPM{Any,Any}) = collect(vprops(x))
listeprops(x::LinearPM{Any,Any}) = collect(eprops(x))


listvprops{V,E}(x::LinearPM{V,E}) = map(string, fieldnames(V))
listeprops{V,E}(x::LinearPM{V,E}) = map(string, fieldnames(E))

################################################# GETVPROP  ################################################################

# Get all properties belonging to a vertex
@inline getvprop(x::LinearPM, v::VertexID) = vdata(x)[v]


# Get all properties for an input vertex list
@inline getvprop(x::LinearPM, vlist::AbstractVector{VertexID}) = vdata(x)[vlist]


# Get the value for a property for a vertex
_getvprop(x::LinearPM{Any,Any}, v::VertexID, propname) = vdata(x)[v][propname]
_getvprop(x::LinearPM, v::VertexID, propname) = getfield(getvprop(x, v), Symbol(propname))

function getvprop(x::LinearPM, v::VertexID, propname)
   check_vprop(x, propname)
   _getvprop(x, v, propname)
end


# Get the value for a property for a list of vertices
function getvprop(x::LinearPM, vlist::AbstractVector{VertexID}, propname)
   check_vprop(x, propname)
   map(v->_getvprop(x, v, propname), vlist)
end


################################################# GETEPROP #################################################################

# Get all properties belonging to an edge
@inline geteprop(x::LinearPM, u::VertexID, v::VertexID) = edata(x)[v,u]
@inline geteprop(x::LinearPM, e::EdgeID) = geteprop(x, e...)


# Get the value of a property for an edge
_geteprop(x::LinearPM{Any,Any}, u::VertexID, v::VertexID, propname) = geteprop(x, u, v)[propname]
_geteprop(x::LinearPM, u::VertexID, v::VertexID, propname) = getfield(geteprop(x, u, v), Symbol(propname))
_geteprop(x::LinearPM, e::EdgeID, propname) = _geteprop(x, e..., propname)

function geteprop(x::LinearPM, u::VertexID, v::VertexID, propname)
   check_eprop(x, propname)
   _geteprop(x, u, v, propname)
end
@inline geteprop(x::LinearPM, e::EdgeID, propname) = geteprop(x, e..., propname)


# Get a dictionary of edge properties for an input edge list
function geteprop(x::LinearPM, elist::AbstractVector{EdgeID})
   map(e->geteprop(x, e), elist)
end

# Get the value of property for an input edge list
function geteprop(x::LinearPM, elist::AbstractVector{EdgeID}, propname)
   check_eprop(x, propname)
   map(e->_geteprop(x, e, propname), elist)
end


################################################# SETVPROP #################################################################

# Set all properties for a vertex
@inline _setvprop!(x::LinearPM{Any,Any}, v::VertexID, d::Dict) = merge!(vdata(x)[v], d)

function _setvprop!(x::LinearPM, v::VertexID, d::Dict)
   for (key,val) in d
      setvprop!(x, v, val, key)
   end
end

function setvprop!(x::LinearPM{Any,Any}, v::VertexID, d::Dict)
   push!(vprops(x), keys(d)...)
   _setvprop!(x, v, d)
   nothing
end

function setvprop!(x::LinearPM, v::VertexID, d::Dict)
   for prop in keys(d)
      check_eprop(x, prop)
   end
   _setvprop!(x, v, d)
   nothing
end


# Set all properties for a list of vertices.
function setvprop!(x::LinearPM, vlist::AbstractVector{VertexID}, dlist::Vector)
   for (v,d) in zip(vlist,dlist)
      setvprop!(x, v, d)
   end
end


# Set a property of a single vertex.
@inline _setvprop!(x::LinearPM, v::VertexID, val, propname) = setfield!(vdata(x)[v], propname, val)
@inline _setvprop!(x::LinearPM{Any,Any}, v::VertexID, val, propname) = setindex!(vdata(x)[v], val, propname)

function setvprop!(x::LinearPM{Any,Any}, v::VertexID, val, propname)
   push!(vprops(x), propname)
   _setvprop!(x, v, val, propname)
end

function setvprop!(x::LinearPM, v::VertexID, val, propname)
   check_vprop(x, propname)
   _setvprop!(x, v, val, Symbol(propname))
   nothing
end


# Set a property for a list of vertices
function _setvprop!(x::LinearPM, vlist::AbstractVector{VertexID}, vals::Vector, propname)
   for (v,val) in zip(vlist,vals)
      _setvprop!(x, v, val, propname)
   end
end

function setvprop!(x::LinearPM{Any,Any}, vlist::AbstractVector{VertexID}, vals::Vector, propname)
   push!(vprops(x), propname)
   _setvprop!(x, vlist, vals, propname)
end

function setvprop!(x::LinearPM, vlist::AbstractVector{VertexID}, vals::Vector, propname)
   check_vprop(x, propname)
   propsym = Symbol(propname)
   _setvprop!(x, vlist, vals, propsym)
end


# Map onto a property for a list of vertices
function _setvprop!(x::LinearPM, vlist::AbstractVector{VertexID}, f::Function, propname)
   for v in vlist
      _setvprop!(x, v, f(v), propname)
   end
end

function setvprop!(x::LinearPM{Any,Any}, vlist::AbstractVector{VertexID}, f::Function, propname)
   push!(vprops(x), propname)
   _setvprop!(x, vlist, f, propname)
end

function setvprop!(x::LinearPM, vlist::AbstractVector{VertexID}, f::Function, propname)
   check_vprop(x, propname)
   propsym  = Symbol(propname)
   _setvprop!(x, vlist, f, propsym)
end


# Set a property for all vertices
function setvprop!(x::LinearPM, ::Colon, vals::Vector, propname)
   setvprop!(x, 1 : length(vdata(x)), vals, propname)
end


# Map onto a property for all vertices
function setvprop!(x::LinearPM, ::Colon, f::Function, propname)
   setvprop!(x, 1 : length(vdata(x)), f, propname)
end


################################################# SETVPROP #################################################################

# Set all properties for an edge
function _seteprop!(x::LinearPM{Any,Any}, u::VertexID, v::VertexID, d::Dict)
   setindex!(edata(x), merge!(edata(x)[v,u], d), v, u)
   nothing
end

function _seteprop!(x::LinearPM, u::VertexID, v::VertexID, d::Dict)
   E = edata(x)[v,u]
   for (key,val) in d
      setfield!(E, Symbol(key), val)
   end
   edata(x)[v,u] = E
   nothing
end

function seteprop!(x::LinearPM{Any,Any}, u::VertexID, v::VertexID, d::Dict)
   push!(vprops(x), keys(d)...)
   _seteprop!(x, u, v, d)
end

function seteprop!(x::LinearPM, u::VertexID, v::VertexID, d::Dict)
   for prop in keys(d)
      check_eprop(x, prop)
   end
   _seteprop!(x, u, v, d)
end
@inline seteprop!(x::LinearPM, e::EdgeID, d::Dict) = seteprop!(x, e..., d)


# Set all properties for a list of edges
function seteprop!(x::LinearPM, elist::AbstractVector{EdgeID}, dlist::Vector)
   for (e,d) in zip(elist,dlist)
      seteprop!(x, e, d)
   end
end


# Set a proprty for an edge
function _seteprop!(x::LinearPM{Any,Any}, u::VertexID, v::VertexID, val, propname)
   d = edata(x)[v,u]
   d[propname] = val
   edata(x)[v,u] = d
   nothing
end

function _seteprop!(x::LinearPM, u::VertexID, v::VertexID, val, propname)
   E = edata(x)[v,u]
   setfield!(E, propname, val)
   edata(x)[v,u] = E
   nothing
end

@inline _seteprop!(x::LinearPM, e::EdgeID, val, propname) = _seteprop!(x, e..., val, propname)

function seteprop!(x::LinearPM{Any,Any}, u::VertexID, v::VertexID, val, propname)
   push!(eprops(x), propname)
   _seteprop!(x, u, v, val, propname)
end

function seteprop!(x::LinearPM, u::VertexID, v::VertexID, val, propname)
   check_eprop(x, propname)
   _seteprop!(x, u, v, val, Symbol(propname))
end
@inline seteprop!(x::LinearPM, e::EdgeID, val, propname) = seteprop!(x, e..., val, propname)


# Set a property for a list of edges
function _seteprop!(x::LinearPM{Any,Any}, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   push!(eprops(x), propname)
   for (e,val) in zip(elist,vals)
      _seteprop!(x, e, val, propname)
   end
end

function _seteprop!(x::LinearPM, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   check_eprop(x, propname)
   propsym = Symbol(propname)
   for (e,val) in zip(elist,vals)
      _seteprop!(x, e, val, propsym)
   end
end

seteprop!(x::LinearPM, elist::AbstractVector{EdgeID}, vals::Vector, propname) = _seteprop!(x, elist, vals, propname)
seteprop!(x::LinearPM, es::EdgeIter, vals::Vector, propname) = _seteprop!(x, collect(es), vals, propname)


# Map onto a property for a list of edges
function _seteprop!(x::LinearPM{Any,Any}, elist::AbstractVector{EdgeID}, f::Function, propname)
   push!(eprops(x), propname)
   for e in elist
      _seteprop!(x, e, f(e...), propname)
   end
end

function _seteprop!(x::LinearPM, elist::AbstractVector{EdgeID}, f::Function, propname)
   check_eprop(x, propname)
   propsym = Symbol(propname)
   for e in elist
      _seteprop!(x, e, f(e...), propsym)
   end
end

seteprop!(x::LinearPM, elist::AbstractVector{EdgeID}, f::Function, propname) = _seteprop!(x, elist, f, propname)
seteprop!(x::LinearPM, es::EdgeIter, f::Function, propname) = seteprop!(x, collect(es), f, propname)

################################################# SUBGRAPH #################################################################

function subgraph{V,E}(x::LinearPM{V,E}, vlist::AbstractVector{VertexID})
   LinearPM{V,E}(copy(vprops(x)), copy(eprops(x)), vdata(x)[vlist], edata(x)[vlist,vlist])
end

# Slow af. But to be fair, this module isn't expected to do this..
function subgraph(x::LinearPM, vlist::AbstractVector{VertexID}, vproplist::AbstractVector)
   y = LinearPM{Any,Any}(Set{Any}(vproplist), copy(eprops(x)), [Dict() for v in vlist], edata(x)[vlist,vlist])
   for prop in vproplist
      vals = getvprop(x, vlist, prop)
      setvprop!(y, vlist, vals, prop)
   end
   y
end



function subgraph{V,E}(x::LinearPM{V,E}, elist::AbstractVector{EdgeID})
   LinearPM{V,E}(copy(vprops(x)), copy(eprops(x)), deepcopy(vdata(x)), splice_matrix(edata(x), elist))
end

# Slow af. But to be fair, this module isn't expected to do this..
function subgraph(x::LinearPM, elist::AbstractVector{EdgeID}, eproplist::AbstractVector)
   nv = length(vdata(x))
   y = LinearPM{Any,Any}(copy(vprops(x)), Set{Any}(eproplist), deepcopy(vdata(x)), spzeros(Dict, nv, nv))
   for prop in eproplist
      vals = geteprop(x, elist, prop)
      seteprop!(y, elist, vals, prop)
   end
   y
end


function subgraph{V,E}(x::LinearPM{V,E}, vlist::AbstractVector{VertexID}, elist::AbstractVector{EdgeID})
   M = splice_matrix(edata(x), elist)[vlist,vlist]
   LinearPM{V,E}(copy(vprops(x)), copy(eprops(x)), vdata(x)[vlist], M)
end

_getfield(d::Dict, key) = d[key]
_getfield(d, key) = getfield(d, Symbol(key))

# PLEASE OPTIMIZE ME
function subgraph(
   x::LinearPM,
   vlist::AbstractVector{VertexID},
   elist::AbstractVector{EdgeID},
   vproplist::AbstractVector,
   eproplist::AbstractVector
   )
   nv = length(vlist)

   VD = sizehint!(Vector{Dict}(), nv)

   for v in vlist
      d = Dict()
      for prop in vproplist
         d[prop] = _getfield(vdata(x)[v], prop)
      end
      push!(VD, d)
   end

   sv = splice_matrix(edata(x), elist)[vlist,vlist]
   elist = sizehint!(Vector{EdgeID}(), nnz(sv))
   nzval = sizehint!(Vector{Dict}(), nnz(sv))

   for u in vlist
      for v in sv.rowval[nzrange(sv, u)]
         d = Dict()
         for prop in eproplist
            d[prop] = _getfield(sv[v,u], prop)
         end
         push!(elist, EdgeID(u,v))
         push!(nzval, d)
      end
   end
   ED = init_spmx(nv, elist, nzval)
   LinearPM{Any,Any}(Set{Any}(vproplist), Set{Any}(eproplist), VD, ED)
end
