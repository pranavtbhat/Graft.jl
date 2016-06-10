################################################# FILE DESCRIPTION #########################################################

# This file contains a dictionary implemenation of the PropertyModule interface. Vertex Properties are stored as 
# (VertexID,Prop) tuples. Edge properties are stored as (Pair{VertexID,VertexID}, Prop) tuples. This is done to avoid 
# maintaining separate dictionaries for each vertex/edge. Two sets, vprops and eprops are used to keep track of the existing
# properties in the property module.

################################################# IMPORT/EXPORT ############################################################

export DictPM

""" A property module that uses sets and dictionaries """
type DictPM{K,V} <: PropertyModule{K,V}
   vprops::Set{K}
   eprops::Set{K}
   data::Dict{Any,V} # Optimize

   function DictPM()
      self = new()
      self.vprops = Set{K}()
      self.eprops = Set{K}()
      self.data = Dict{Any,V}()
      self
   end
end

@inline data(x::DictPM) = x.data

@inline vprops(x::DictPM) = x.vprops

@inline eprops(x::DictPM) = x.eprops

################################################# INTERNAL IMPLEMENTATION ##################################################

listvprops{K,V}(x::DictPM{K,V}) = collect(vprops(x))

listeprops{K,V}(x::DictPM{K,V}) = collect(eprops(x))

function getvprop{K,V}(x::DictPM{K,V}, v::VertexID)
   D = data(x)
   [prop => get(D, (v,prop), nothing) for prop in vprops(x)]
end

@inline getvprop{K,V}(x::DictPM{K,V}, v::VertexID, prop) = get(data(x), (v,prop), nothing)

function geteprop{K,V}(x::DictPM{K,V}, u::VertexID, v::VertexID)
   D = data(x)
   [prop => get(D, (u=>v,prop), nothing) for prop in eprops(x)]
end

@inline geteprop{K,V}(x::DictPM{K,V}, u::VertexID, v::VertexID, prop) = get(data(x), (u=>v,prop), nothing)

function setvprop!{K,V}(x::DictPM{K,V}, v::VertexID, props::Dict)
   for (key,val) in props
      setvprop!(x, v, key, val)
   end
end

function setvprop!{K,V}(x::DictPM{K,V}, v::VertexID, prop, val)
   push!(vprops(x), prop)
   setindex!(data(x), val, (v,prop))
   nothing
end

function seteprop!{K,V}(x::DictPM{K,V}, u::VertexID, v::VertexID, props::Dict)
   for (key,val) in props
      seteprop!(x, u, v, key, val)
   end
end

function seteprop!{K,V}(x::DictPM{K,V}, u::VertexID, v::VertexID, prop, val)
   push!(eprops(x), prop)
   setindex!(data(x), val, (u=>v,prop))
   nothing
end

################################################# INTERFACE IMPLEMENTATION #################################################

@inline listvprops{AM,K,V}(g::Graph{AM,DictPM{K,V}}) = listvprops(propmod(g))
@inline listeprops{AM,K,V}(g::Graph{AM,DictPM{K,V}}) = listeprops(propmod(g))
@inline getvprop{AM,K,V}(g::Graph{AM,DictPM{K,V}}, v::VertexID) = getvprop(propmod(g), v)
@inline getvprop{AM,K,V}(g::Graph{AM,DictPM{K,V}}, v::VertexID, prop) = getvprop(propmod(g), v, prop)
@inline geteprop{AM,K,V}(g::Graph{AM,DictPM{K,V}}, u::VertexID, v::VertexID) = geteprop(propmod(g), u, v)
@inline geteprop{AM,K,V}(g::Graph{AM,DictPM{K,V}}, u::VertexID, v::VertexID, prop) = geteprop(propmod(g), u, v, prop)
@inline setvprop!{AM,K,V}(g::Graph{AM,DictPM{K,V}}, v::VertexID, props::Dict) = setvprop!(propmod(g), v, props)
@inline setvprop!{AM,K,V}(g::Graph{AM,DictPM{K,V}}, v::VertexID, prop, val) = setvprop!(propmod(g), v, prop, val)
@inline seteprop!{AM,K,V}(g::Graph{AM,DictPM{K,V}}, u::VertexID, v::VertexID, props::Dict) = seteprop!(propmod(g), u, v, props)
@inline seteprop!{AM,K,V}(g::Graph{AM,DictPM{K,V}}, u::VertexID, v::VertexID, prop, val) = seteprop!(propmod(g), u, v, prop, val)

################################################# SUBGRAPH #################################################################

function subgraph{K,V}(x::DictPM{K,V}, vlist::AbstractVector{VertexID})
   D = data(x)
   y = DictPM{K,V}()

   for v in vlist
      for prop in vprops(x)
         val = getvprop(x, v, prop)
         val != nothing && setvprop!(y, v, prop, val)
      end
   end

   vlen = length(vlist)

   for i in 1 : vlen
      for j in i+1 : vlen
         u = vlist[i]
         v = vlist[j]
         for prop in eprops(x)
            val = geteprop(x, u, v, prop)
            val != nothing && seteprop!(y, u, v, prop, val)
         end
      end
   end

   y
end

