################################################# FILE DESCRIPTION #########################################################

# This file contains the DictArrPM implementation of the PropertyModule interface. Separate dictionaries are maintained for
# vertex and edge proerties. The vertex property dictionary maps onto arrays of values, while the edge property dictionary
# maps onto sparesematrices of values.

################################################# IMPORT/EXPORT ############################################################

export 
# Types
DictArrPM

""" A property module that uses sets and dictionaries """
type DictArrPM{K,V} <: PropertyModule{K,V}
   nv::Int
   vdata::Dict{K,Any}
   edata::Dict{K,Any}

   function DictArrPM(nv::Int, vdata::Dict{K,Any}, edata::Dict{K,Any})
      self = new()
      self.nv = nv
      self.vdata = vdata
      self.edata = edata
      self
   end

   function DictArrPM(nv::Int=0)
      self = new()
      self.nv = nv
      self.vdata = Dict{K,Any}()
      self.edata = Dict{K,Any}()
      self
   end
end

function DictArrPM(nv::Int=0)
   DictArrPM{ASCIIString,Any}(nv)
end

@inline nv(x::DictArrPM) = x.nv
@inline vdata(x::DictArrPM) = x.vdata
@inline edata(x::DictArrPM) = x.edata

################################################# INTERNAL IMPLEMENTATION ##################################################

# Default value helpers
default{T}(::AbstractArray{T}) = zero(T)

function default_vprop{T}(::Type{T}, sz::Int)
   fill!(Array{T}(sz), zero(T))
end

default_eprop{T}(::Type{T}, sz::Int) = spzeros(T, sz, sz)

function addvertex!{K,V}(x::DictArrPM{K,V}, nv::Int=1)
   E = edata(x)
   for (key,arr) in vdata(x)
      resize!(arr, length(arr) + nv)
   end

   for key in keys(E)
      E[key] = grow(E[key], nv)
   end
   x.nv += nv
   nothing
end

function rmvertex!{K,V}(x::DictArrPM{K,V}, v::VertexID) # Need to find a way to Nullify values.
   for (key,arr) in vdata(x)
      arr[v] = default(arr)
   end

   for (key,arr) in edata(x)
      arr[v] = default(arr)
   end

   nothing
end

addedge!{K,V}(x::DictArrPM{K,V}, u::VertexID, v::VertexID) = nothing

function rmedge!{K,V}(x::DictArrPM{K,V}, u::VertexID, v::VertexID)
   for (key,arr) in edata(x)
      arr[u,v] = default(arr)
   end
   nothing
end

listvprops{K,V}(x::DictArrPM{K,V}) = collect(keys(vdata(x)))

listeprops{K,V}(x::DictArrPM{K,V}) = collect(keys(edata(x)))

function getvprop{K,V}(x::DictArrPM{K,V}, v::VertexID)
   [prop=>arr[v] for (prop,arr) in vdata(x)]
end

function getvprop{K,V}(x::DictArrPM{K,V}, v::VertexID, prop)
   get!(vdata(x), prop, default_vprop(V, nv(x)))[v]
end

function geteprop{K,V}(x::DictArrPM{K,V}, u::VertexID, v::VertexID)
   [prop=>arr[u,v] for (prop,arr) in edata(x)]
end

function geteprop{K,V}(x::DictArrPM{K,V}, u::VertexID, v::VertexID, prop)
   get!(edata(x), prop, default_eprop(V, nv(x)))[u,v]
end

function setvprop!{K,V}(x::DictArrPM{K,V}, v::VertexID, props::Dict)
   for (key,val) in props
      setvprop!(x, v, key, val)
   end
end

function setvprop!{K,V}(x::DictArrPM{K,V}, v::VertexID, prop, val)
   get!(vdata(x), prop, default_vprop(V, nv(x)))[v] = val
   nothing
end

# Should be fast.
function setvprop!{K,V}(x::DictArrPM{K,V}, vlist::AbstractVector, vals::Vector, propname)
   length(vlist) == length(vals) || error("Lenght of value vector must equal the number of vertices in the graph")
   vdata(x)[propname] = vals
   nothing
end

function setvprop!{K,V}(x::DictArrPM{K,V}, vlist::AbstractVector, f::Function, propname)
   setvprop!(x, vlist, map(f, vlist), propname)
   nothing
end


function seteprop!{K,V}(x::DictArrPM{K,V}, u::VertexID, v::VertexID, props::Dict)
   for (key,val) in props
      seteprop!(x, u, v, key, val)
   end
end

function seteprop!{K,V}(x::DictArrPM{K,V}, u::VertexID, v::VertexID, prop, val)
   get!(edata(x), prop, default_eprop(V, nv(x)))[u,v] = val
   nothing
end

# Should be fast.
function seteprop!{K,V}(x::DictArrPM{K,V}, f::Function, propname, edges)
   sv = get!(edata(x), propname, default_eprop(V, nv(x)))
   for e in edges
      u,v = e
      sv[u,v] = f(u,v)
   end
   nothing
end


################################################# SUBGRAPH #################################################################

function subgraph{K,V}(x::DictArrPM{K,V}, vlist::AbstractVector{VertexID})
   VD = Dict{K,Any}()
   ED = Dict{K,Any}()

   for (key,arr) in vdata(x)
      VD[key] = arr[vlist]
   end

   for (key,arr) in edata(x)
      ED[key] = arr[vlist,vlist]
   end
   DictArrPM{K,V}(nv(x), VD, ED)
end

function subgraph{K,V,I<:Integer}(x::DictArrPM{K,V}, elist::Vector{Pair{I,I}})
   VD = deepcopy(vdata(x))
   ED = Dict{K,Any}()

   for (key,arr) in edata(x)
      sv = default_eprop(V, nv(x))
      for e in elist
         sv[e...] = arr[e...]
      end
      ED[key] = sv
   end
   DictArrPM{K,V}(nv(x), VD, ED)
end