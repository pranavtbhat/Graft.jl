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

listvprops{AM,K,V}(g::Graph{AM,DictPM{K,V}}) = collect(vprops(propmod(g)))

listeprops{AM,K,V}(g::Graph{AM,DictPM{K,V}}) = collect(eprops(propmod(g)))

function getvprop{AM,K,V}(g::Graph{AM,DictPM{K,V}}, v::VertexID)
   x = propmod(g)
   D = data(x)
   [prop => D[(v,prop)] for prop in vprops(x)]
end

@inline getvprop{AM,K,V}(g::Graph{AM,DictPM{K,V}}, v::VertexID, prop) = data(propmod(g))[(v,prop)]

function geteprop{AM,K,V}(g::Graph{AM,DictPM{K,V}}, u::VertexID, v::VertexID)
   x = propmod(g)
   D = data(x)
   [prop => D[(u=>v,prop)] for prop in eprops(x)]
end

@inline geteprop{AM,K,V}(g::Graph{AM,DictPM{K,V}}, u::VertexID, v::VertexID, prop) = data(propmod(g))[(u=>v,prop)]

function setvprop!{AM,K,V}(g::Graph{AM,DictPM{K,V}}, v::VertexID, props::Dict)
   for (key,val) in props
      setvprop!(g, v, key, val)
   end
end

function setvprop!{AM,K,V}(g::Graph{AM,DictPM{K,V}}, v::VertexID, prop, val)
   x = propmod(g)
   push!(vprops(x), prop)
   setindex!(data(x), val, (v,prop))
   nothing
end

function seteprop!{AM,K,V}(g::Graph{AM,DictPM{K,V}}, u::VertexID, v::VertexID, props::Dict)
   for (key,val) in props
      seteprop!(g, u, v, key, val)
   end
end

function seteprop!{AM,K,V}(g::Graph{AM,DictPM{K,V}}, u::VertexID, v::VertexID, prop, val)
   x = propmod(g)
   push!(eprops(x), prop)
   setindex!(data(x), val, (u=>v,prop))
   nothing
end
