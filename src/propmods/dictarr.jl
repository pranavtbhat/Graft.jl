################################################# FILE DESCRIPTION #########################################################

# This file contains the DictArrPM implementation of the PropertyModule interface. Separate dictionaries are maintained for
# vertex and edge proerties. The vertex property dictionary maps onto arrays of values, while the edge property dictionary
# maps onto sparesematrices of values.

################################################# IMPORT/EXPORT ############################################################

export 
# Types
DictArrPM

type DictArrPM{V,E} <: WeaklyTypedPM{V,E}
   nv::Int
   vdata::Dict
   edata::Dict
end

# Simple constructor for casual usage
function DictArrPM(nv::Int=0)
   DictArrPM{Any,Any}(nv, Dict(), Dict())
end

@inline nv(x::DictArrPM) = x.nv
@inline vdata(x::DictArrPM) = x.vdata
@inline edata(x::DictArrPM) = x.edata

################################################# INTERNAL IMPLEMENTATION ##################################################

function propmote_vertex_type!{T}(x::DictArrPM, ::Type{T}, propname)
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

propmote_vertex_type!{T}(x::DictArrPM, val::AbstractVector{T}, propname) = propmote_vertex_type!(x, T, propname)
propmote_vertex_type!(x::DictArrPM, val, propname) = propmote_vertex_type!(x, typeof(val), propname)


function propmote_edge_type!{T}(x::DictArrPM, ::Type{T}, propname)
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

propmote_edge_type!{T}(x::DictArrPM, val::Vector{T}, propname) = propmote_edge_type!(x, T, propname)
propmote_edge_type!(x::DictArrPM, val, propname) = propmote_edge_type!(x, typeof(val), propname)

################################################# INTERFACE IMPLEMENTATION #################################################

function Base.deepcopy(x::DictArrPM)
   DictArrPM(nv(x), deepcopy(vdata(x)), deepcopy(edata(x)))
end



function addvertex!(x::DictArrPM, nv::Int=1)
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




function rmvertex!(x::DictArrPM, v)
   D = edata(x)
   for arr in values(vdata(x))
      deleteat!(arr, v)
   end

   for key in keys(D)
      D[key] = remove_cols(D[key], v)
   end

   nothing
end


addedge!(x::DictArrPM, u::VertexID, v::VertexID) = nothing
addedge!(x::DictArrPM, e::EdgeID) = nothing
addedge!(x::DictArrPM, es::AbstractVector{EdgeID}) = nothing


function rmedge!(x::DictArrPM, u::VertexID, v::VertexID)
   for arr in values(edata(x))
      delete_entry!(arr, u, v)
   end
   nothing
end
@inline rmedge!(x::DictArrPM, e::EdgeID) = rmedge!(x, e...)

function rmedge!(x::DictArrPM, elist::AbstractVector{EdgeID})
   for e in elist
      rmedge!(x, e)
   end
end



listvprops(x::DictArrPM) = collect(keys(vdata(x)))
listeprops(x::DictArrPM) = collect(keys(edata(x)))


# Get all properties belonging to a vertex
function getvprop(x::DictArrPM, v::VertexID)
   d = Dict()
   for (prop,arr) in vdata(x)
      if arr[v] != zero(eltype(arr))
         d[prop] = arr[v]
      end
   end
   d
end

# Get a dictionary of vertex properties for an input vertex list
function getvprop(x::DictArrPM, vlist::AbstractVector{VertexID})
   res = [Dict() for v in vlist]
   for (key,arr) in vdata(x), (i,v) in enumerate(vlist)
      if arr[v] != zero(eltype(arr))
         res[i][key] = arr[v]
      end
   end
   res
end

# Get the value for a property for a vertex
function getvprop(x::DictArrPM, v::VertexID, propname)
   haskey(vdata(x), propname) || nothing
   vdata(x)[propname][v]
end

# Get the value for a property for a list of vertices
function getvprop(x::DictArrPM, vlist::AbstractVector{VertexID}, propname)
   haskey(vdata(x), propname) || fill(nothing, length(vlist))
   vdata(x)[propname][vlist]
end



# Get all properties belonging to an edge
function geteprop(x::DictArrPM, u::VertexID, v::VertexID)
   d = Dict()
   for (prop,arr) in edata(x)
      if arr[v,u] != zero(eltype(arr))
         d[prop] =arr[v,u]
      end
   end
   d
end
@inline geteprop(x::DictArrPM, e::EdgeID) = geteprop(x, e...)

# Get the value of a property for an edge
function geteprop(x::DictArrPM, u::VertexID, v::VertexID, propname)
   haskey(edata(x), propname) || nothing
   edata(x)[propname][v,u]
end
@inline geteprop(x::DictArrPM, e::EdgeID, propname) = geteprop(x, e..., propname)

# Get a dictionary of edge properties for an input edge list
function geteprop(x::DictArrPM, elist::AbstractVector{EdgeID})
   res = [Dict() for i in 1 : length(elist)]
   for (key,arr) in edata(x), (i,e) in enumerate(elist)
      u,v = e
      if arr[v,u] != zero(eltype(arr))
         res[i][key] = arr[v,u]
      end
   end
   res
end

# Get the value of property for an input edge list
function geteprop(x::DictArrPM, elist::AbstractVector{EdgeID}, propname)
   haskey(edata(x), propname) || fill(nothing, length(elist))
   sv = edata(x)[propname]
   [sv[v,u] for (u,v) in elist]
end



# Set all properties for a vertex.
function setvprop!(x::DictArrPM, v::VertexID, d::Dict)
   for (key,val) in d
      setvprop!(x, v, val, key)
   end
   nothing
end

# Set all properties for a list of vertices.
function setvprop!(x::DictArrPM, vlist::AbstractVector{VertexID}, dlist::Vector)
   for (v,d) in zip(vlist,dlist)
      setvprop!(x, v, d)
   end
   nothing
end

# Set a property of a single vertex.
function setvprop!(x::DictArrPM, v::VertexID, val, propname)
   propmote_vertex_type!(x, val, propname)
   vdata(x)[propname][v] = val
   nothing
end


# Set a property for a list of vertices
function setvprop!(x::DictArrPM, vlist::AbstractVector{VertexID}, vals::Vector, propname)
   propmote_vertex_type!(x, vals, propname)
   vdata(x)[propname][vlist] = vals
   nothing
end

# Map onto a property for a list of vertices
function setvprop!(x::DictArrPM, vlist::AbstractVector{VertexID}, f::Function, propname)
   setvprop!(x, vlist, map(f, vlist), propname)
end

# Set a property for all vertices
function setvprop!(x::DictArrPM, ::Colon, vals::Vector, propname)
   vdata(x)[propname] = vals
   nothing
end

# map onto a property for all vertices
function setvprop!(x::DictArrPM, ::Colon, f::Function, propname)
   setvprop!(x, :, map(f, 1 : nv(x)), propname)
end



# Set all properties for an edge
function seteprop!(x::DictArrPM, u::VertexID, v::VertexID, d::Dict)
   for (key,val) in d
      seteprop!(x, u, v, val, key)
   end
end
@inline seteprop!(x::DictArrPM, e::EdgeID, d::Dict) = seteprop!(x, e..., d)

# Set all properties for a list of edges
function seteprop!(x::DictArrPM, elist::AbstractVector{EdgeID}, dlist::Vector)
   for (e,d) in zip(elist,dlist)
      seteprop!(x, e, d)
   end
   nothing
end

# Set a proprty for an edge
function seteprop!(x::DictArrPM, u::VertexID, v::VertexID, val, propname)
   propmote_edge_type!(x::DictArrPM, val, propname)
   edata(x)[propname][v,u] = val
   nothing
end
@inline seteprop!(x::DictArrPM, e::EdgeID, val, propname) = seteprop!(x, e..., val, propname)

# Set a property for a list of edges
function seteprop!(x::DictArrPM, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   propmote_edge_type!(x::DictArrPM, vals, propname)
   sv = edata(x)[propname]
   for (i,e) in enumerate(elist)
      u,v=e
      sv[v,u] = vals[i]
   end
   nothing
end

# Map onto a property for a list of edges
function seteprop!(x::DictArrPM, elist::AbstractVector{EdgeID}, f::Function, propname)
   seteprop!(x, elist, map(e->f(e...), elist), propname)
end

# Set a property for all edges
function seteprop!(x::DictArrPM, ::Colon, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   edata(x)[propname] = init_spmx(nv(x), elist, vals)
   nothing
end

# Map onto a property for all edges
function seteprop!(x::DictArrPM, ::Colon, elist::AbstractVector{EdgeID}, f::Function, propname)
   seteprop!(x, :, elist, map(e->f(e...), elist), propname)
end

################################################# SUBGRAPH #################################################################

function subgraph(x::DictArrPM, vlist::AbstractVector{VertexID})
   VD = [key=>arr[vlist] for (key,arr) in vdata(x)]
   ED = [key=>arr[vlist,vlist] for (key,arr) in edata(x)]
   DictArrPM{Any,Any}(nv(x), VD, ED)
end

function subgraph(x::DictArrPM, elist::AbstractVector{EdgeID})
   VD = deepcopy(vdata(x))
   ED = Dict()

   for (key,arr) in edata(x)
      vals = [arr[e...] for e in elist]
      VD[key] = init_spmx(nv(x), elist, vals)
   end
   
   DictArrPM{Any,Any}(nv(x), VD, ED)
end