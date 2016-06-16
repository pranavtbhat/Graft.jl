################################################# FILE DESCRIPTION #########################################################

# This file contains a dictionary implemenation of the PropertyModule interface. PureDictPM is exptected to be quite slow. 
# Two sets, vprops and eprops are used to keep track of the existing properties in the property module.

################################################# IMPORT/EXPORT ############################################################

export PureDictPM

""" A property module that uses sets and dictionaries """
type PureDictPM{K,V} <: PropertyModule{K,V}
   vprops::Set{K}
   eprops::Set{K}
   data::Dict{Any,Dict}

   function PureDictPM(vprops::Set{K}, eprops::Set{K}, data::Dict{Any,Dict})
      self = new()
      self.vprops = vprops
      self.eprops = eprops
      self.data = data
      self
   end

   function PureDictPM(nv::Int=0)
      self = new()
      self.vprops = Set{K}()
      self.eprops = Set{K}()
      self.data = Dict{Any,Dict}()
      self
   end
end

function PureDictPM(nv::Int=0)
   PureDictPM{ASCIIString,Any}()
end

@inline data(x::PureDictPM) = x.data

@inline vprops(x::PureDictPM) = x.vprops

@inline eprops(x::PureDictPM) = x.eprops

################################################# INTERNAL IMPLEMENTATION ##################################################

addvertex!{K,V}(x::PureDictPM{K,V}) = nothing

function rmvertex!{K,V}(x::PureDictPM{K,V}, v::VertexID) # Optimize
   D = data(x)
   delete!(D, v)
   for key in keys(D)
      isa(key, Pair) && (key[1] == v || key[2] == v) && delete!(D, key)
   end
   nothing
end

addedge!{K,V}(x::PureDictPM{K,V}, u::VertexID, v::VertexID) = nothing

function rmedge!{K,V}(x::PureDictPM{K,V}, u::VertexID, v::VertexID)
   delete!(data(x), u=>v)
   nothing
end

listvprops{K,V}(x::PureDictPM{K,V}) = collect(vprops(x))

listeprops{K,V}(x::PureDictPM{K,V}) = collect(eprops(x))

function getvprop{K,V}(x::PureDictPM{K,V}, v::VertexID)
   get(data(x), v, Dict{K,V}())
end

function getvprop{K,V}(x::PureDictPM{K,V}, v::VertexID, prop)
   D = get(data(x), v, Dict{K,V}())
   get(D, prop, nothing)
end

function geteprop{K,V}(x::PureDictPM{K,V}, u::VertexID, v::VertexID)
   get(data(x), u=>v, Dict{K,V}())
end

function geteprop{K,V}(x::PureDictPM{K,V}, u::VertexID, v::VertexID, prop)
   D = get(data(x), u=>v, Dict{K,V}())
   get(D, prop, nothing)
end

function setvprop!{K,V}(x::PureDictPM{K,V}, v::VertexID, props::Dict)
   for (key,val) in props
      setvprop!(x, v, key, val)
   end
end

function setvprop!{K,V}(x::PureDictPM{K,V}, v::VertexID, prop, val)
   push!(vprops(x), prop)
   D = get!(data(x), v, Dict{K,V}())
   D[prop] = val
   nothing
end

function seteprop!{K,V}(x::PureDictPM{K,V}, u::VertexID, v::VertexID, props::Dict)
   for (key,val) in props
      seteprop!(x, u, v, key, val)
   end
end

function seteprop!{K,V}(x::PureDictPM{K,V}, u::VertexID, v::VertexID, prop, val)
   push!(eprops(x), prop)
   D = get!(data(x), u=>v, Dict{K,V}())
   D[prop] = val
   nothing
end

################################################# SUBGRAPH #################################################################

function subgraph{K,V}(x::PureDictPM{K,V}, vlist::AbstractVector{VertexID})
   D = data(x)
   new_vid = Dict([v=>i for (i,v) in enumerate(vlist)])
   y = PureDictPM{K,V}(copy(vprops(x)), copy(eprops(x)), Dict{Any,Dict}())
   D_ = data(y)

   for key in keys(D)
      if isa(key, VertexID) && key in vlist
         u = new_vid[key]
         D_[u] = copy(D[key])
      elseif isa(key, Pair) && key.first in vlist && key.second in vlist
         u = new_vid[key.first]
         v = new_vid[key.second]
         D_[u=>v] = copy(D[key])
      end
   end
   y
end

function subgraph{K,V,I<:Integer}(x::PureDictPM{K,V}, elist::Vector{Pair{I,I}})
   D = data(x)
   y = PureDictPM{K,V}(copy(vprops(x)), copy(eprops(x)), Dict{Any,Dict}())
   D_ = data(y)

   for key in keys(D)
      if isa(key, VertexID) && haskey(D, key)
         D_[key] = D[key]
      end
   end

   for e in elist
      if haskey(D, e)
         D_[e] = D[e]
      end
   end
   y
end