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

################################################# IMPLEMENTATION ############################################################

listvprops{K,V}(x::DictPM{K,V}) = collect(vprops(x))

listeprops{K,V}(x::DictPM{K,V}) = collect(eprops(x))

@inline getvprop{K,V}(x::DictPM{K,V}, v::VertexID) = [prop => data(x)[(v,prop)] for prop in vprops(x)]

@inline getvprop{K,V}(x::DictPM{K,V}, v::VertexID, prop) = data(x)[(v,prop)]

@inline geteprop{K,V}(x::DictPM{K,V}, u::VertexID, v::VertexID) = [prop => data(x)[(u=>v,prop)] for prop in eprops(x)]

@inline geteprop{K,V}(x::DictPM{K,V}, u::VertexID, v::VertexID, prop) = data(x)[(u=>v,prop)]

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
