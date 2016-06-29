################################################# FILE DESCRIPTION #########################################################

# This file contains a vectorized implementation of the PropertyModule interface. Separate dictionaries are maintained for
# vertex and edge proerties. The vertex property dictionary maps onto arrays of values, while the edge property dictionary
# maps onto sparesematrices of values. 

################################################# IMPORT/EXPORT ############################################################

export 
# Types
VectorPM

type VectorPM{V,E} <: PropertyModule{V,E}
   nv::Int
   vdata::Dict
   edata::Dict

   function VectorPM(nv::Int=0)
      self = new()
      self.nv = nv

      if V == Any
         self.vdata = Dict()
      else
         self.vdata = init_vprop_dict(V, nv)
      end

      if E == Any
         self.edata = Dict()
      else
         self.edata = init_eprop_dict(E, nv)
      end

      self
   end

   function VectorPM(nv::Int, vdata::Dict, edata::Dict)
      self = new()
      self.nv = nv
      self.vdata = vdata
      self.edata = edata
      self
   end
end

function VectorPM(nv::Int=0)
   VectorPM{Any,Any}(nv)
end

@inline nv(x::VectorPM) = x.nv
@inline vdata(x::VectorPM) = x.vdata
@inline edata(x::VectorPM) = x.edata

################################################# INTERNAL IMPLEMENTATION ##################################################

# Validate vertex property
@inline function check_vprop(x::VectorPM, propname)
   haskey(vdata(x), propname) || error("Vertex has no property: $propname")
end

# Validate edge property
@inline function check_eprop(x::VectorPM, propname)
   haskey(edata(x), propname) || error("Edge has no property: $propname")
end


# Initialize vprop array
function init_vprop_dict(T::DataType, nv::Int)
   [string(field) => default_vector(fieldtype(T, field), nv) for field in fieldnames(T)]
end

# Initialize eprop array
function init_eprop_dict(T::DataType, nv::Int)
   [string(field) => default_matrix(fieldtype(T, field), nv) for field in fieldnames(T)]
end


# Perform a type join to ensure type compatibility with vprop array
function propmote_vertex_type!{T}(x::VectorPM, ::Type{T}, propname)
   D = vdata(x)
   if haskey(D, propname)
      arr = D[propname]
      if !(eltype(arr) <: T)
         D[propname] = Array{typejoin(eltype(arr), T)}(arr)
      end
   else
      D[propname] = default_vector(T, nv(x))
   end
   nothing
end

propmote_vertex_type!{T}(x::VectorPM, val::AbstractVector{T}, propname) = propmote_vertex_type!(x, T, propname)
propmote_vertex_type!(x::VectorPM, val, propname) = propmote_vertex_type!(x, typeof(val), propname)


# Perform a type join to ensure type compatibility with eprop array
function propmote_edge_type!{T}(x::VectorPM, ::Type{T}, propname)
   D = edata(x)
   if haskey(D, propname)
      arr = D[propname]
      if !(eltype(arr) <: T)
         D[propname] = SparseMatrixCSC{typejoin(eltype(arr), T), Int}(arr)
      end
   else
      D[propname] = default_matrix(T, nv(x))
   end
   nothing
end

propmote_edge_type!{T}(x::VectorPM, val::Vector{T}, propname) = propmote_edge_type!(x, T, propname)
propmote_edge_type!(x::VectorPM, val, propname) = propmote_edge_type!(x, typeof(val), propname)

################################################# COPYING ##################################################################

function Base.deepcopy(x::VectorPM)
   VectorPM(nv(x), deepcopy(vdata(x)), deepcopy(edata(x)))
end

################################################# MUTATION #################################################################

# Add nv vertices
function addvertex!(x::VectorPM, nv::Int=1)
   E = edata(x)
   for arr in values(vdata(x))
      append!(arr, zeros(eltype(arr), nv))
   end

   for key in keys(E)
      E[key] = grow(E[key], nv)
   end
   x.nv += nv
   nothing
end


# Remove vertex(s)
function rmvertex!(x::VectorPM, v)
   D = edata(x)
   for arr in values(vdata(x))
      deleteat!(arr, v)
   end

   for key in keys(D)
      D[key] = remove_cols(D[key], v)
   end

   nothing
end


# Add edge(s)
addedge!(x::VectorPM, u::VertexID, v::VertexID) = nothing
addedge!(x::VectorPM, e::EdgeID) = nothing
addedge!(x::VectorPM, es::AbstractVector{EdgeID}) = nothing


# Remove edges(s)
function rmedge!(x::VectorPM, u::VertexID, v::VertexID)
   for arr in values(edata(x))
      delete_entry!(arr, u, v)
   end
   nothing
end
@inline rmedge!(x::VectorPM, e::EdgeID) = rmedge!(x, e...)

function rmedge!(x::VectorPM, elist::AbstractVector{EdgeID})
   for e in elist
      rmedge!(x, e)
   end
end


################################################# LIST PROPS ###############################################################

listvprops(x::VectorPM{Any,Any}) = collect(keys(vdata(x)))
listeprops(x::VectorPM{Any,Any}) = collect(keys(edata(x)))

listvprops{V,E}(x::VectorPM{V,E}) = map(string, fieldnames(V))
listeprops{V,E}(x::VectorPM{V,E}) = map(string, fieldnames(E))

################################################# GETVPROP  ################################################################

# Get all properties belonging to a vertex
function getvprop(x::VectorPM{Any,Any}, v::VertexID)
   [prop=>arr[v] for (prop,arr) in vdata(x)]
end

function getvprop{V,E}(x::VectorPM{V,E}, v::VertexID)
   V([vdata(x)[string(field)][v] for field in fieldnames(V)]...)
end


# Get a dictionary of vertex properties for an input vertex list
function getvprop(x::VectorPM, vlist::AbstractVector{VertexID})
   map(v->getvprop(x, v), vlist)
end


# Get the value for a property for a vertex
_getvprop(x::VectorPM, v::VertexID, propname) = vdata(x)[propname][v]

function getvprop(x::VectorPM, v::VertexID, propname)
   check_vprop(x, propname)
   _getvprop(x, v, propname)
end


# Get the value for a property for a list of vertices
_getvprop(x::VectorPM, vlist::AbstractVector{VertexID}, propname) = vdata(x)[propname][vlist]

function getvprop(x::VectorPM, vlist::AbstractVector{VertexID}, propname)
   check_vprop(x, propname)
   _getvprop(x, vlist, propname)   
end

################################################# GETEPROP  ################################################################

# Get all properties belonging to an edge
function geteprop(x::VectorPM{Any,Any}, u::VertexID, v::VertexID)
   [prop => arr[v,u] for (prop,arr) in edata(x)]
end

function geteprop{V,E}(x::VectorPM{V,E}, u::VertexID, v::VertexID)
   E([edata(x)[string(field)][v,u] for field in fieldnames(E)]...)
end

@inline geteprop(x::VectorPM, e::EdgeID) = geteprop(x, e...)


# Get the value of a property for an edge
_geteprop(x::VectorPM, u::VertexID, v::VertexID, propname) = edata(x)[propname][v,u]
_geteprop(x::VectorPM, e::EdgeID, propname) = _geteprop(x, e..., propname)

function geteprop(x::VectorPM, u::VertexID, v::VertexID, propname)
   check_eprop(x, propname)
   _geteprop(x, u, v, propname)
end
@inline geteprop(x::VectorPM, e::EdgeID, propname) = geteprop(x, e..., propname)


# Get a dictionary of edge properties for an input edge list
function geteprop(x::VectorPM{Any,Any}, elist::AbstractVector{EdgeID})
   dlist = [Dict() for i in 1:length(elist)]
   for (key,arr) in edata(x)
      vals = geteprop(x, elist, key)
      for (i,d) in enumerate(dlist)
         d[key] = vals[i]
      end
   end
   dlist
end

function geteprop{V,E}(x::VectorPM{V,E}, elist::AbstractVector{EdgeID})
   tlist = [zero(E) for i in 1:length(elist)]
   for (key,arr) in edata(x)
      propsym = Symbol(key)
      vals = geteprop(x, elist, key)
      for (i,t) in enumerate(tlist)
         setfield!(t, propsym, vals[i])
      end
   end
   tlist
end


# Get the value of property for an input edge list
function geteprop(x::VectorPM, elist::AbstractVector{EdgeID}, propname)
   check_eprop(x, propname)
   sv = edata(x)[propname]
   [sv[v,u] for (u,v) in  elist]
end


################################################# SETVPROP  ################################################################

# Set all properties for a vertex.
function setvprop!(x::VectorPM, v::VertexID, d::Dict)
   for (key,val) in d
      setvprop!(x, v, val, key)
   end
end


# Set all properties for a list of vertices.
function setvprop!(x::VectorPM, vlist::AbstractVector{VertexID}, dlist::Vector)
   for (v,d) in zip(vlist,dlist)
      setvprop!(x, v, d)
   end
end


# Set a property of a single vertex.
function _setvprop!(x::VectorPM, v::VertexID, val, propname)
   vdata(x)[propname][v] = val
   nothing
end

function setvprop!(x::VectorPM{Any,Any}, v::VertexID, val, propname)
   propmote_vertex_type!(x, val, propname)
   _setvprop!(x, v, val, propname)
end

function setvprop!(x::VectorPM, v::VertexID, val, propname)
   check_vprop(x, propname)
   _setvprop!(x, v, val, propname)
end


# Set a property for a list of vertices
function _setvprop!(x::VectorPM, vlist::AbstractVector{VertexID}, vals::Vector, propname)
   vdata(x)[propname][vlist] = vals
end

function setvprop!(x::VectorPM{Any,Any}, vlist::AbstractVector{VertexID}, vals::Vector, propname)
   propmote_vertex_type!(x, vals, propname)
   _setvprop!(x, vlist, vals, propname)
end

function setvprop!(x::VectorPM, vlist::AbstractVector{VertexID}, vals::Vector, propname)
   check_vprop(x, propname)
   _setvprop!(x, vlist, vals, propname)
end


# Map onto a property for a list of vertices
function setvprop!(x::VectorPM, vlist::AbstractVector{VertexID}, f::Function, propname)
   setvprop!(x, vlist, map(f, vlist), propname)
end


# Set a property for all vertices
function _setvprop!(x::VectorPM, ::Colon, vals::Vector, propname)
   vdata(x)[propname] = vals
end

function setvprop!(x::VectorPM{Any,Any}, ::Colon, vals::Vector, propname)
   _setvprop!(x, :, vals, propname)
end

function setvprop!(x::VectorPM, ::Colon, vals::Vector, propname)
   check_vprop(x, propname)
   _setvprop!(x, :, vals, propname)
end


# map onto a property for all vertices
function setvprop!(x::VectorPM, ::Colon, f::Function, propname)
   setvprop!(x, :, map(f, 1 : nv(x)), propname)
end


################################################# SETEPROP  ################################################################

# Set all properties for an edge
function seteprop!(x::VectorPM, u::VertexID, v::VertexID, d::Dict)
   for (key,val) in d
      seteprop!(x, u, v, val, key)
   end
end
@inline seteprop!(x::VectorPM, e::EdgeID, d::Dict) = seteprop!(x, e..., d)

# Set all properties for a list of edges
function seteprop!(x::VectorPM, elist::AbstractVector{EdgeID}, dlist::Vector)
   for (e,d) in zip(elist,dlist)
      seteprop!(x, e, d)
   end
   nothing
end

# Set a proprty for an edge
function _seteprop!(x::VectorPM, u::VertexID, v::VertexID, val, propname)
   edata(x)[propname][v,u] = val
end

function seteprop!(x::VectorPM{Any,Any}, u::VertexID, v::VertexID, val, propname)
   propmote_edge_type!(x::VectorPM, val, propname)
   _seteprop!(x, u, v, val, propname)
end

function seteprop!(x::VectorPM, u::VertexID, v::VertexID, val, propname)
   check_eprop(x, propname)
   _seteprop!(x, u, v, val, propname)
end

@inline seteprop!(x::VectorPM, e::EdgeID, val, propname) = seteprop!(x, e..., val, propname)


# Set a property for a list of edges
function _seteprop!(x::VectorPM, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   sv = edata(x)[propname]
   for (i,(u,v)) in enumerate(elist)
      sv[v,u] = vals[i]
   end
   nothing
end

function seteprop!(x::VectorPM{Any,Any}, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   propmote_edge_type!(x::VectorPM, vals, propname)
   _seteprop!(x, elist, vals, propname)
end

function seteprop!(x::VectorPM, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   check_eprop(x, propname)
   _seteprop!(x, elist, vals, propname)
end


# Map onto a property for a list of edges
function seteprop!(x::VectorPM, elist::AbstractVector{EdgeID}, f::Function, propname)
   seteprop!(x, elist, map(e->f(e...), elist), propname)
end


# Set a property for all edges
function _seteprop!(x::VectorPM, ::Colon, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   edata(x)[propname] = init_spmx(nv(x), elist, vals)
end

function seteprop!(x::VectorPM{Any,Any}, ::Colon, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   _seteprop!(x, :, elist, vals, propname)
end

function seteprop!(x::VectorPM, ::Colon, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   check_eprop(x, propname)
   _seteprop!(x, :, elist, vals, propname)
end

# Map onto a property for all edges
function seteprop!(x::VectorPM, ::Colon, elist::AbstractVector{EdgeID}, f::Function, propname)
   seteprop!(x, :, elist, map(e->f(e...), elist), propname)
end


################################################# SUBGRAPH #################################################################

function subgraph{V,E}(x::VectorPM{V,E}, vlist::AbstractVector{VertexID})
   VD = [key=>arr[vlist] for (key,arr) in vdata(x)]
   ED = [key=>arr[vlist,vlist] for (key,arr) in edata(x)]
   VectorPM{V,E}(nv(x), VD, ED)
end

function subgraph{V,E}(x::VectorPM{V,E}, elist::AbstractVector{EdgeID})
   VD = deepcopy(vdata(x))
   ED = Dict()

   for (key,arr) in edata(x)
      vals = [arr[e...] for e in elist]
      VD[key] = init_spmx(nv(x), elist, vals)
   end
   
   VectorPM{V,E}(nv(x), VD, ED)
end