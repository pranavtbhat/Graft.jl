################################################# FILE DESCRIPTION #########################################################

# This file contains the TypeArrPM implementation of the PropertyModule interface. Separate dictionaries are maintained for
# vertex and edge proerties. The vertex property dictionary maps onto arrays of values, while the edge property dictionary
# maps onto sparesematrices of values.

################################################# IMPORT/EXPORT ############################################################

export 
# Types
TypeArrPM

type TypeArrPM{V,E} <: StronglyTypedPM{V,E}
   nv::Int
   vdata::Dict
   edata::Dict

   function TypeArrPM(nv::Int=0)
      self = new()
      self.nv = nv
      self.vdata = init_vprop_dict(V, nv)
      self.edata = init_eprop_dict(E, nv)
      self
   end

   function TypeArrPM(nv::Int, vdata::Dict, edata::Dict)
      self = new()
      self.nv = nv
      self.vdata = vdata
      self.edata = edata
      self
   end
end

@inline nv(x::TypeArrPM) = x.nv
@inline vdata(x::TypeArrPM) = x.vdata
@inline edata(x::TypeArrPM) = x.edata

################################################# INTERNAL IMPLEMENTATION ##################################################

function init_vprop_dict(T::DataType, nv::Int)
   [string(field) => default_vector(fieldtype(T, field), nv) for field in fieldnames(T)]
end

function init_eprop_dict(T::DataType, nv::Int)
   [string(field) => default_matrix(fieldtype(T, field), nv) for field in fieldnames(T)]
end
################################################# INTERFACE IMPLEMENTATION #################################################

function Base.deepcopy(x::TypeArrPM)
   TypeArrPM(nv(x), deepcopy(vdata(x)), deepcopy(edata(x)))
end



function addvertex!(x::TypeArrPM, nv::Int=1)
   for arr in values(vdata(x))
      append!(arr, fill(zero(eltype(arr)), nv))
   end

   for (key,arr) in edata(x)
      edata(x)[key] = grow(arr, nv)
   end

   x.nv += nv
   nothing
end



function rmvertex!(x::TypeArrPM, v)
   for arr in values(vdata(x))
      deleteat!(arr, v)
   end

   for (key,val) in edata(x)
      edata(x)[key] = remove_cols(val, v)
   end

   nothing
end


addedge!(x::TypeArrPM, u::VertexID, v::VertexID) = nothing
addedge!(x::TypeArrPM, e::EdgeID) = nothing
addedge!(x::TypeArrPM, es::AbstractVector{EdgeID}) = nothing


function rmedge!(x::TypeArrPM, u::VertexID, v::VertexID)
   for arr in values(edata(x))
      delete_entry!(arr, u, v)
   end
   nothing
end
@inline rmedge!(x::TypeArrPM, e::EdgeID) = rmedge!(x, e...)

function rmedge!(x::TypeArrPM, elist::AbstractVector{EdgeID})
   for e in elist
      rmedge!(x, e)
   end
end



listvprops{V,E}(x::TypeArrPM{V,E}) = map(string, fieldnames(V))
listeprops{V,E}(x::TypeArrPM{V,E}) = map(string, fieldnames(E))



# Get all properties belonging to a vertex
function getvprop{V,E}(x::TypeArrPM{V,E}, v::VertexID)
   V([vdata(x)[string(field)][v] for field in fieldnames(V)]...)
end

# Get a dictionary of vertex properties for an input vertex list
function getvprop(x::TypeArrPM, vlist::AbstractVector{VertexID})
   map(v->getvprop(x, v), vlist)
end

# Get the value for a property for a vertex
function getvprop(x::TypeArrPM, v::VertexID, propname)
   haskey(vdata(x), propname) || nothing
   vdata(x)[propname][v]
end

# Get the value for a property for a list of vertices
function getvprop(x::TypeArrPM, vlist::AbstractVector{VertexID}, propname)
   haskey(vdata(x), propname) || fill(nothing, length(vlist))
   vdata(x)[propname][vlist]
end



# Get all properties belonging to an edge
function geteprop{V,E}(x::TypeArrPM{V,E}, u::VertexID, v::VertexID)
   E([edata(x)[string(field)][v,u] for field in fieldnames(E)]...)
end
@inline geteprop(x::TypeArrPM, e::EdgeID) = geteprop(x, e...)

# Get the value of a property for an edge
function geteprop(x::TypeArrPM, u::VertexID, v::VertexID, propname)
   haskey(edata(x), propname) || nothing
   edata(x)[propname][v,u]
end
@inline geteprop(x::TypeArrPM, e::EdgeID, propname) = geteprop(x, e..., propname)

# Get a dictionary of edge properties for an input edge list
function geteprop(x::TypeArrPM, elist::AbstractVector{EdgeID})
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
function geteprop(x::TypeArrPM, elist::AbstractVector{EdgeID}, propname)
   haskey(edata(x), propname) || fill(nothing, length(elist))
   sv = edata(x)[propname]
   [sv[v,u] for (u,v) in elist]
end



# Set all properties for a vertex.
function setvprop!(x::TypeArrPM, v::VertexID, d::Dict)
   for (key,val) in d
      setvprop!(x, v, val, key)
   end
   nothing
end

# Set all properties for a list of vertices.
function setvprop!(x::TypeArrPM, vlist::AbstractVector{VertexID}, dlist::Vector)
   for (v,d) in zip(vlist,dlist)
      setvprop!(x, v, d)
   end
   nothing
end

# Set a property of a single vertex.
function setvprop!(x::TypeArrPM, v::VertexID, val, propname)
   haskey(vdata(x), propname) || error("Vertex Property $propname not found")
   vdata(x)[propname][v] = val
   nothing
end


# Set a property for a list of vertices
function setvprop!(x::TypeArrPM, vlist::AbstractVector{VertexID}, vals::Vector, propname)
   haskey(vdata(x), propname) || error("Vertex Property $propname not found")
   vdata(x)[propname][vlist] = vals
   nothing
end

# Map onto a property for a list of vertices
function setvprop!(x::TypeArrPM, vlist::AbstractVector{VertexID}, f::Function, propname)
   setvprop!(x, vlist, map(f, vlist), propname)
end

# Set a property for all vertices
function setvprop!(x::TypeArrPM, ::Colon, vals::Vector, propname)
   haskey(vdata(x), propname) || error("Vertex Property $propname not found")
   vdata(x)[propname] = vals
   nothing
end

# map onto a property for all vertices
function setvprop!(x::TypeArrPM, ::Colon, f::Function, propname)
   haskey(vdata(x), propname) || error("Vertex Property $propname not found")
   setvprop!(x, :, map(f, 1 : nv(x)), propname)
end



# Set all properties for an edge
function seteprop!(x::TypeArrPM, u::VertexID, v::VertexID, d::Dict)
   for (key,val) in d
      seteprop!(x, u, v, val, key)
   end
end
@inline seteprop!(x::TypeArrPM, e::EdgeID, d::Dict) = seteprop!(x, e..., d)

# Set all properties for a list of edges
function seteprop!(x::TypeArrPM, elist::AbstractVector{EdgeID}, dlist::Vector)
   for (e,d) in zip(elist,dlist)
      seteprop!(x, e, d)
   end
   nothing
end

# Set a proprty for an edge
function seteprop!(x::TypeArrPM, u::VertexID, v::VertexID, val, propname)
   haskey(edata(x), propname) || error("Edge Property $propname not found")
   edata(x)[propname][v,u] = val
   nothing
end
@inline seteprop!(x::TypeArrPM, e::EdgeID, val, propname) = seteprop!(x, e..., val, propname)

# Set a property for a list of edges
function seteprop!(x::TypeArrPM, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   haskey(edata(x), propname) || error("Edge Property $propname not found")
   sv = edata(x)[propname]
   for (i,e) in enumerate(elist)
      u,v=e
      sv[v,u] = vals[i]
   end
   nothing
end

# Map onto a property for a list of edges
function seteprop!(x::TypeArrPM, elist::AbstractVector{EdgeID}, f::Function, propname)
   haskey(edata(x), propname) || error("Edge Property $propname not found")
   seteprop!(x, elist, map(e->f(e...), elist), propname)
end

# Set a property for all edges
function seteprop!(x::TypeArrPM, ::Colon, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   haskey(edata(x), propname) || error("Edge Property $propname not found")
   edata(x)[propname] = init_spmx(nv(x), elist, vals)
   nothing
end

# Map onto a property for all edges
function seteprop!(x::TypeArrPM, ::Colon, elist::AbstractVector{EdgeID}, f::Function, propname)
   haskey(edata(x), propname) || error("Edge Property $propname not found")
   seteprop!(x, :, elist, map(e->f(e...), elist), propname)
end

################################################# SUBGRAPH #################################################################

function subgraph{V,E}(x::TypeArrPM{V,E}, vlist::AbstractVector{VertexID})
   VD = [key=>arr[vlist] for (key,arr) in vdata(x)]
   ED = [key=>arr[vlist,vlist] for (key,arr) in edata(x)]
   TypeArrPM{V,E}(nv(x), VD, ED)
end

function subgraph{V,E}(x::TypeArrPM{V,E}, elist::AbstractVector{EdgeID})
   VD = deepcopy(vdata(x))
   ED = Dict()

   for (key,arr) in edata(x)
      vals = [arr[e...] for e in elist]
      VD[key] = init_spmx(nv(x), elist, vals)
   end
   
   TypeArrPM{V,E}(nv(x), VD, ED)
end