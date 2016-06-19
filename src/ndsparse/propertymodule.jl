################################################# FILE DESCRIPTION #########################################################

# This file contains the NDSparsePM, a property module that uses NDSparseArrays to store vertex and edge properties.

################################################# IMPORT/EXPORT ############################################################
export 
# Types
NDSparsePM

""" A property module that uses NDSparse arrays """
type NDSparsePM{K,V} <: PropertyModule{K,V}
   vprops::Set{K}
   eprops::Set{K}
   data::AbstractArray

   function NDSparsePM(vprops::Set{K}, eprops::Set{K}, data::AbstractArray)
      self = new()
      self.vprops = vprops
      self.eprops = eprops
      self.data = data
      self
   end

   function NDSparsePM(nv::Int=0)
      self = new{K,V}()
      self.vprops = Set{K}()
      self.eprops = Set{K}()
      self.data = NDSparse((MAX_VERTEX,MAX_VERTEX,MAX_VERTEX), Int[], Int[], K[], V[])
      self
   end
end

function NDSparsePM(nv::Int=0)
   NDSparsePM{ASCIIString,Any}()
end

@inline data(x::NDSparsePM) = x.data

@inline vprops(x::NDSparsePM) = x.vprops

@inline eprops(x::NDSparsePM) = x.eprops

################################################# INTERNAL IMPLEMENTATION #################################################

addvertex!{K,V}(x::NDSparsePM{K,V}) = nothing

function rmvertex!{K,V}(x::NDSparsePM{K,V}, v::VertexID)
   # Won't work until delete / colon resolution for setindex! is implemented in NDSparse 
   # data(x)[v,:,:] = nothing
   # data(x)[:,v,:] = nothing
end

addedge!{K,V}(x::NDSparsePM{K,V}, u::VertexID, v::VertexID) = nothing

function rmedge!{K,V}(x::NDSparsePM{K,V}, u::VertexID, v::VertexID)
   # Won't work until delete / colon resolution for setindex! is implemented in NDSparse 
   # data(x)[u,v,:] = nothing
end 

listvprops{K,V}(x::NDSparsePM{K,V}) = collect(vprops(x))

listeprops{K,V}(x::NDSparsePM{K,V}) = collect(eprops(x))

function getvprop{K,V}(x::NDSparsePM{K,V}, v::VertexID)
   result = data(x)[v,v,:] 
   D = result.data
   I = result.indexes
   [I[i][3] => D[i] for i in eachindex(I)]
end

getvprop{K,V}(x::NDSparsePM{K,V}, v::VertexID, prop) = data(x)[v, v, prop]

function geteprop{K,V}(x::NDSparsePM{K,V}, u::VertexID, v::VertexID)
   result = data(x)[u,v,:]
   D = result.data
   I = result.indexes
   [I[i][3] => D[i] for i in eachindex(I)]
end

geteprop{K,V}(x::NDSparsePM{K,V}, u::VertexID, v::VertexID, prop) = data(x)[u, v, prop]

function setvprop!{K,V}(x::NDSparsePM{K,V}, v::VertexID, props::Dict)
   for (key,val) in props
      setvprop!(x, v, key, val)
   end
end

function setvprop!{K,V}(x::NDSparsePM{K,V}, v::VertexID, prop, val)
   push!(vprops(x), prop)
   setindex!(data(x), val, v, v, prop)
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

################################################# SUBGRAPH ################################################################


function subgraph{K,V}(x::NDSparsePM{K,V}, vlist::AbstractVector{VertexID})
   D = data(x)[vlist, vlist, :]
   cols = D.indexes.columns

   flush!(D)
   new_vid = Dict([v=>i for (i,v) in enumerate(vlist)])
   map!(v->new_vid[v], cols[1], cols[1])
   map!(v->new_vid[v], cols[2], cols[2])

   NDSparsePM{K,V}(copy(vprops(x)), copy(eprops(x)), D)
end

function subgraph{K,V,E<:Integer}(x::NDSparsePM{K,V}, elist::Vector{Pair{E,E}}) 
   # Need a better filter for NDSparse. Submit PR to NDSparse to resolve this mess.
   arr = data(x)
   I = arr.indexes
   cols = I.columns
   indxs = collect(1 : length(I))

   filter!(indxs) do i
      t = I[i]
      t[1] == t[2] && return true
      in((t[1]=>t[2]), elist) && return true
   end

   arr_ = NDSparse(size(arr), Indexes(map(x->x[indxs], cols)...), arr.data[indxs], arr.default)
   NDSparsePM{K,V}(copy(vprops(x)), copy(eprops(x)), arr_)
end
