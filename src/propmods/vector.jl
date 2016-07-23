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

# Initialize vprop array
function init_vprop_dict(T::DataType, nv::Int)
   Dict(string(field) => default_vector(fieldtype(T, field), nv) for field in fieldnames(T))
end

# Initialize eprop array
function init_eprop_dict(T::DataType, nv::Int)
   Dict(string(field) => default_matrix(fieldtype(T, field), nv) for field in fieldnames(T))
end

################################################# VALIDATION ###############################################################

# Perform a type join to ensure type compatibility with vprop array
function propmote_vertex_type!{T}(x::VectorPM{Any,Any}, ::Type{T}, propname)
   D = vdata(x)
   if haskey(D, propname)
      arr = D[propname]
      if !(T <: eltype(arr))
         D[propname] = Array{typejoin(eltype(arr), T)}(arr)
      end
   else
      D[propname] = default_vector(T, nv(x))
   end
   nothing
end

# Reject invalid property names and types
function propmote_vertex_type!{T}(x::VectorPM, ::Type{T}, propname)
   haskey(vdata(x), propname) || error("Illegal property name $propname")

   # Disable this check till 0.5
   # (T <: eltype(vdata(x)[propname])) || error("Illegal data type $T for property $propname")
   nothing
end

propmote_vertex_type!{T}(x::VectorPM, val::AbstractVector{T}, propname) = propmote_vertex_type!(x, T, propname)
propmote_vertex_type!(x::VectorPM, val, propname) = propmote_vertex_type!(x, typeof(val), propname)


# Perform a type join to ensure type compatibility with eprop array
function propmote_edge_type!{T}(x::VectorPM{Any,Any}, ::Type{T}, propname)
   D = edata(x)
   if haskey(D, propname)
      arr = D[propname]
      if !(T <: eltype(arr))
         D[propname] = SparseMatrixCSC{typejoin(eltype(arr), T), Int}(arr)
      end
   else
      D[propname] = default_matrix(T, nv(x))
   end
   nothing
end

# Reject invalid property names and types
function propmote_edge_type!{T}(x::VectorPM, ::Type{T}, propname)
   haskey(edata(x), propname) || error("Illegal property name $propname")

   # Disable this check till 0.5
   # (T <: eltype(edata(x)[propname])) || error("Illegal data type $T for property $propname")
end

propmote_edge_type!{T}(x::VectorPM, val::Vector{T}, propname) = propmote_edge_type!(x, T, propname)
propmote_edge_type!(x::VectorPM, val, propname) = propmote_edge_type!(x, typeof(val), propname)

################################################# COPYING ##################################################################

function Base.deepcopy{V,E}(x::VectorPM{V,E})
   VectorPM{V,E}(nv(x), deepcopy(vdata(x)), deepcopy(edata(x)))
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

hasvprop(x::VectorPM, prop) = haskey(vdata(x), prop)
haseprop(x::VectorPM, prop) = haskey(edata(x), prop)

listvprops(x::VectorPM{Any,Any}) = collect(keys(vdata(x)))
listeprops(x::VectorPM{Any,Any}) = collect(keys(edata(x)))

listvprops{V,E}(x::VectorPM{V,E}) = map(string, fieldnames(V))
listeprops{V,E}(x::VectorPM{V,E}) = map(string, fieldnames(E))

################################################# SUBGRAPH #################################################################

function subgraph{V,E}(x::VectorPM{V,E}, vlist::AbstractVector{VertexID})
   VD = Dict(key=>arr[vlist] for (key,arr) in vdata(x))
   ED = Dict(key=>arr[vlist,vlist] for (key,arr) in edata(x))
   VectorPM{V,E}(nv(x), VD, ED)
end

function subgraph(x::VectorPM, vlist::AbstractVector{VertexID}, vproplist::AbstractVector)
   VD = Dict(prop=>vdata(x)[prop][vlist] for prop in vproplist)
   ED = Dict(key=>arr[vlist,vlist] for (key,arr) in edata(x))
   VectorPM{Any,Any}(nv(x), VD, ED)
end


function subgraph{V,E}(x::VectorPM{V,E}, elist::AbstractVector{EdgeID})
   VD = deepcopy(vdata(x))
   ED = Dict(key=>splice_matrix(arr, elist) for (key,arr) in edata(x))
   VectorPM{V,E}(nv(x), VD, ED)
end

function subgraph(x::VectorPM, elist::AbstractVector{EdgeID}, eproplist::AbstractVector)
   VD = deepcopy(vdata(x))
   ED = Dict(prop=>splice_matrix(edata(x)[prop], elist) for prop in eproplist)
   VectorPM{Any,Any}(nv(x), VD, ED)
end


function subgraph{V,E}(x::VectorPM{V,E}, vlist::AbstractVector{VertexID}, elist::AbstractVector{EdgeID})
   VD = Dict(key=>arr[vlist] for (key,arr) in vdata(x))
   ED = Dict(key=>splice_matrix(arr, elist)[vlist,vlist] for (key,arr) in edata(x))
   VectorPM{V,E}(length(vlist), VD, ED)
end

function subgraph(
   x::VectorPM,
   vlist::AbstractVector{VertexID},
   elist::AbstractVector{EdgeID},
   vproplist::AbstractVector,
   eproplist::AbstractVector
   )
   VD = Dict(prop => vdata(x)[prop][vlist] for prop in vproplist)
   ED = Dict(prop => splice_matrix(edata(x)[prop], elist)[vlist,vlist] for prop in eproplist)
   VectorPM{Any,Any}(length(vlist), VD, ED)
end
