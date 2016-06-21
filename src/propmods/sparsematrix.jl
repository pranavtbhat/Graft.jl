################################################# FILE DESCRIPTION #########################################################

# This file contains a SparseMatrix implemenation of the PropertyModule interface. This module is currently very slow for 
# large datasets. It would be more advisable to use DictArrPM.

################################################# IMPORT/EXPORT ############################################################

export SparseMatrixPM

type SparseMatrixPM{K,V} <: PropertyModule{K,V}
   vprops::Set{K}
   eprops::Set{K}
   data::SparseMatrixCSC{Dict{K,V}}

   function SparseMatrixPM(vprops::Set{K}, eprops::Set{K}, data::SparseMatrixCSC{Dict{K,V}})
      self = new()
      self.vprops = vprops
      self.eprops = eprops
      self.data = data
      self
   end

   function SparseMatrixPM(nv::Int=0)
      self = new()
      self.vprops = Set{K}()
      self.eprops = Set{K}()
      self.data = spzeros(Dict{K,V}, nv, nv) 
      self
   end
end

function SparseMatrixPM(nv::Int=0)
   SparseMatrixPM{ASCIIString,Any}(nv)
end


@inline vprops(x::SparseMatrixPM) = x.vprops
@inline eprops(x::SparseMatrixPM) = x.eprops
@inline data(x::SparseMatrixPM) = x.data

# Set zero to Dict{K,V}().
Base.zero{K,V}(::Type{Dict{K,V}}) = Dict{K,V}()

################################################# INTERNAL IMPLEMENTATION ##################################################

function addvertex!{K,V}(x::SparseMatrixPM{K,V}, nv::Int=1)
   x.data = grow(data(x), nv)
   nothing
end

function rmvertex!{K,V}(x::SparseMatrixPM{K,V}, v::VertexID)
   empty!(data(x)[v,v])
   map(empty!, nonzeros(data(x)[v,:]))
   map(empty!, nonzeros(data(x)[:,v]))
   nothing
end

function addedge!{K,V}(x::SparseMatrixPM{K,V}, u::VertexID, v::VertexID)
   data(x)[u,v] = Dict{K,V}()
end

function rmedge!{K,V}(x::SparseMatrixPM{K,V}, u::VertexID, v::VertexID)
   empty!(data(x)[u,v])
   nothing
end

listvprops{K,V}(x::SparseMatrixPM{K,V}) = collect(vprops(x))

listeprops{K,V}(x::SparseMatrixPM{K,V}) = collect(eprops(x))

@inline getvprop{K,V}(x::SparseMatrixPM{K,V}, v::VertexID) = data(x)[v,v]

function getvprop{K,V}(x::SparseMatrixPM{K,V}, v::VertexID, prop)
   get(getvprop(x, v), prop, nothing)
end

@inline geteprop{K,V}(x::SparseMatrixPM{K,V}, u::VertexID, v::VertexID) = data(x)[u,v]

function geteprop{K,V}(x::SparseMatrixPM{K,V}, u::VertexID, v::VertexID, prop)
   get(geteprop(x, u, v), prop, nothing)
end

function setvprop!{K,V}(x::SparseMatrixPM{K,V}, v::VertexID, props::Dict)
   data(x)[v,v] = merge!(data(x)[v,v], props)
   push!(vprops(x), keys(props)...)
   nothing
end

function setvprop!{K,V}(x::SparseMatrixPM{K,V}, v::VertexID, prop, val)
   data(x)[v,v] = push!(data(x)[v,v], prop=>val)
   push!(vprops(x), prop)
   nothing
end

function setvprop!{K,V}(x::SparseMatrixPM{K,V}, vlist::AbstractVector, vals::Vector, propname)
   length(vlist) == length(vals) || error("Lenght of value vector must equal the number of vertices in the graph")
   push!(vprops(x), propname)
   D = data(x)

   for i in eachindex(vlist, vals)
      v = vlist[i]
      d = D[v,v]
      d[propname] = vals[i]
      D[v,v] = d
   end
   nothing
end


function setvprop!{K,V}(x::SparseMatrixPM{K,V}, vlist::AbstractVector, f::Function, propname)
   setvprop!(x, vlist, map(f, vlist), propname)
end



function seteprop!{K,V}(x::SparseMatrixPM{K,V}, u::VertexID, v::VertexID, props::Dict)
   data(x)[v,v] = merge!(data(x)[u,v], props)
   push!(eprops(x), keys(props)...)
   nothing
end

function seteprop!{K,V}(x::SparseMatrixPM{K,V}, u::VertexID, v::VertexID, prop, val)
   data(x)[u,v] = push!(data(x)[u,v], prop=>val)
   push!(eprops(x), prop)
   nothing
end

function seteprop!{K,V}(x::SparseMatrixPM{K,V}, f::Function, propname, edges)
   push!(eprops(x), propname)
   D = data(x)

   for e in edges
      u,v = e
      d = D[u,v]
      d[propname] = f(u,v)
      D[u,v] = d
   end
   nothing
end

################################################# SUBGRAPH #################################################################

function subgraph{K,V}(x::SparseMatrixPM{K,V}, vlist::AbstractVector{VertexID})
   SparseMatrixPM{K,V}(copy(vprops(x)), copy(eprops(x)), data(x)[vlist,vlist])
end

function subgraph{K,V,I<:Integer}(x::SparseMatrixPM{K,V}, elist::Vector{Pair{I,I}})
   M = data(x)
   N = spzeros(Dict{K,V}, size(M)...)
   N[diagind(M)] = M[diagind(M)]

   for e in elist
      N[e...] = copy(M[e...])
   end
   SparseMatrixPM{K,V}(copy(vprops(x)), copy(eprops(x)), N)
end