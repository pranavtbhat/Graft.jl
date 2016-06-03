################################################# FILE DESCRIPTION #########################################################

# This file contains the NDSparsePM, a property module that uses NDSparseArrays to store vertex and edge properties.

################################################# IMPORT/EXPORT ############################################################
export 
# Types
NDSparsePM, NDSparseArray,
# Constants
NDSparsePM_Max_Size

Base.zero(::Type{Any}) = nothing
Base.zero(::Type{ASCIIString}) = ""

""" A property module that uses NDSparse arrays """
type NDSparsePM{K,V} <: PropertyModule{K,V}
   vprops::Set{K}
   eprops::Set{K}
   data::Any

   function NDSparsePM()
      self = new{K,V}()
      self.vprops = Set{K}()
      self.eprops = Set{K}()
      self.data = NDSparse((MAX_VERTEX,MAX_VERTEX,MAX_VERTEX), Int[], Int[], K[], V[])
      self
   end
end


@inline data(x::NDSparsePM) = x.data

@inline vprops(x::NDSparsePM) = x.vprops

@inline eprops(x::NDSparsePM) = x.eprops

################################################# INTERFACE IMPLEMENTATION #################################################


listvprops{K,V}(x::NDSparsePM{K,V}) = collect(vprops(x)) # How do I do this?

listeprops{K,V}(x::NDSparsePM{K,V}) = collect(eprops(x)) # How do I do this?

function getvprop{K,V}(x::NDSparsePM{K,V}, v::VertexID) # Messy
   flush!(data(x))
   cols = data(x).indexes.columns
   D = data(x).data
   r = searchsorted(cols[1], v)
   idxs = searchsorted(cols[2], 0, first(r), last(r), Base.Order.Forward)
   [cols[3][idx] => D[idx] for idx in idxs]
end

@inline getvprop{K,V}(x::NDSparsePM{K,V}, v::VertexID, prop) = data(x)[v, 0, prop]

function geteprop{K,V}(x::NDSparsePM{K,V}, u::VertexID, v::VertexID) # Messy
   flush!(data(x))
   cols = data(x).indexes.columns
   D = data(x).data
   r = searchsorted(cols[1], u)
   idxs = searchsorted(cols[2], v, first(r), last(r), Base.Order.Forward)
   [cols[3][idx] => D[idx] for idx in idxs]
end

@inline geteprop{K,V}(x::NDSparsePM{K,V}, u::VertexID, v::VertexID, prop) = data(x)[u, v, prop]

function setvprop!{K,V}(x::NDSparsePM{K,V}, v::VertexID, props::Dict)
   for (key,val) in props
      setvprop!(x, v, key, val)
   end
end

function setvprop!{K,V}(x::NDSparsePM{K,V}, v::VertexID, prop, val)
   push!(vprops(x), prop)
   setindex!(data(x), val, v, 0, prop)
   nothing
end

function seteprop!{K,V}(x::NDSparsePM{K,V}, u::VertexID, v::VertexID, props::Dict)
   for (key,val) in props
      seteprop!(x, u, v, key, val)
   end
end

function seteprop!{K,V}(x::NDSparsePM{K,V}, u::VertexID, v::VertexID, prop, val)
   push!(eprops(x), prop)
   setindex!(data(x), val, u, v, prop)
   nothing
end
