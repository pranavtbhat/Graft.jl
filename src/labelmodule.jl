################################################# FILE DESCRIPTION #########################################################

# ParallelGraphs allows users to refer to vertices externally, through arbitrary Julia types. The LabelModule is responsible
# for the resolution of these arbitrary objects into the internally used Integer indices.

################################################# IMPORT/EXPORT ############################################################

export
# Types
LabelMap, LabelModule,
# LabelMaps
IdentityLM,
# Implementation
setlabel!, haslabel, resolve, encode

abstract LabelMap{T}

""" A type to map VertexIDs to Labels """
type LabelModule
   lmap::LabelMap
end

lmap(x::LabelModule) = x.lmap
nv(x::LabelModule) = nv(lmap(x))

################################################# CONSTRUCTORS ########################################################

LabelModule(nv::Int) = LabelModule(IdentityLM(nv))

LabelModule(labels::AbstractVector) = LabelModule(DictLM(labels))

################################################# IDENTITYLM ##########################################################

type IdentityLM <: LabelMap{Int}
   nv::Int
end

nv(x::IdentityLM) = x.nv

################################################# DICTLM ##############################################################

# Label to VertexID
type DictLM{T} <: LabelMap{T}
   nv::Int
   fmap::Dict{T,VertexID}
   rmap::Vector{T}
end

function DictLM{T}(labels::AbstractVector{T})
   nv = length(labels)
   fmap = Dict(l => i for (i,l) in enumerate(labels))
   DictLM{T}(nv, fmap, copy(labels))
end

# Convert from IdentityLM
DictLM(x::IdentityLM) = DictLM([i for i in 1 : nv(x)])


# Accessors
nv(x::DictLM) = x.nv
fmap(x::DictLM) = x.fmap
rmap(x::DictLM) = x.rmap
Base.eltype{T}(x::DictLM{T}) = T

# Type compatibility
type_promote{Tv}(x::DictLM, l::Tv) = type_promote(x, Tv)
type_promote{Tv}(x::DictLM, ls::AbstractVector{Tv}) = type_promote(x, Tv)

function type_promote{T,Tv}(x::DictLM{T}, ::Type{Tv})
   Tn = typejoin(T, Tv)
   DictLM{Tn}(nv(x), Dict{Tn,VertexID}(fmap(x)), Array{Tn}(rmap(x)))
end


################################################# DEEPCOPY #############################################################

Base.deepcopy(x::LabelModule) = LabelModule(deepcopy(lmap(x)))

Base.deepcopy(x::IdentityLM) = IdentityLM(nv(x))

Base.deepcopy(x::DictLM) = DictLM(nv(x), deepcopy(fmap(x)), deepcopy(rmap(x)))

################################################# SETLABEL SINGLE ######################################################

function setlabel!(x::LabelModule)
   x.lmap = IdentityLM(nv(x))
   nothing
end

function setlabel!(x::LabelModule, v::VertexID, l)
   x.lmap = setlabel!(lmap(x), v, l)
   nothing
end

setlabel!(x::IdentityLM, v::VertexID, l) = setlabel!(DictLM(x), v, l)

function setlabel!{T}(x::DictLM{T}, v::VertexID, l::T)
   fmap(x)[l] = v
   rmap(x)[v] = l
   nothing
end
setlabel!(x::DictLM, v::VertexID, l) =  setlabel!(type_promote(x, l), v, l)

################################################# SETLABEL MUTLI ######################################################

function setlabel!(x::LabelModule, ls::AbstractVector)
   x.lmap = DictLM(ls)
   nothing
end

function setlabel!(x::LabelModule, vs::AbstractVector{VertexID}, ls::AbstractVector)
   x.lmap = setlabel!(lmap(x), vs, ls)
   nothing
end

function setlabel!(x::IdentityLM, vs::AbstractVector{VertexID}, ls::AbstractVector)
   setlabel!(DictLM(x), vs, ls)
end

function setlabel!{T}(x::DictLM{T}, vs::AbstractVector{VertexID}, ls::AbstractVector{T})
   broadcast(setlabel!, x, vs, ls)
   rmap(x)[vs] = ls
   nothing
end
setlabel!(x::DictLM, vs::AbstractVector{VertexID}, ls::AbstractVector) =  setlabel!(type_promote(x, ls), vs, ls)

################################################# HASLABEL ############################################################

haslabel(x::LabelModule, l) = haslabel(lmap(x), l)
haslabel(x::IdentityLM, v::VertexID) = 1 <= v <= nv(x)
haslabel(x::IdentityLM, l) = false
haslabel(x::DictLM, l) = haskey(fmap(x), l)

################################################# RESOLVE VERTEX ############################################################

resolve(x::LabelModule, l) = resolve(lmap(x), l)
resolve(x::IdentityLM, v::VertexID) = v
resolve(x::IdentityLM, l) = error("Couldn't resolve vertex label $l")

function resolve(x::DictLM, l)
   get(fmap(x), l) do
      error("Couldn't resolve vertex label $l")
   end
end

################################################# RESOLVE VERTICES ##########################################################

resolve(x::LabelModule, ls::AbstractVector) = resolve(lmap(x), ls)
resolve(x::LabelModule, vs::AbstractVector{VertexID}) = vs
resolve(x::DictLM, ls::AbstractVector) = broadcast(resolve, [x], ls)

################################################# RESOLVE EDGE ##############################################################

resolve(x::LabelModule, u, v) = resolve(lmap(x), u, v)
resolve(x::IdentityLM, u::VertexID, v::VertexID) = EdgeID(u, v)
resolve(x::DictLM, ul, vl) = EdgeID(resolve(x, ul), resolve(x, vl))

################################################# ENCODE VERTEX ############################################################

encode(x::LabelModule, v::VertexID) = encode(lmap(x), v)
encode(x::IdentityLM, v::VertexID) = v
encode(x::DictLM, v::VertexID) = getindex(rmap(x), v)

################################################# ENCODE VERTICES ##########################################################

encode(x::LabelModule, vs::AbstractVector{VertexID}) = encode(lmap(x), vs)
encode(x::IdentityLM, vs::AbstractVector{VertexID}) = vs
encode(x::DictLM, vs::AbstractVector{VertexID}) = getindex(rmap(x), vs)

################################################# ENCODE EDGE ##############################################################

encode(x::LabelModule, e::EdgeID) = encode(lmap(x), e)
encode(x::IdentityLM, e::EdgeID) = e
encode{T}(x::DictLM{T}, e::EdgeID) = Pair{T,T}(encode(x, e.first), encode(x, e.second))

################################################# ENCODE EDGES #############################################################

encode(x::LabelModule, es::AbstractVector{EdgeID}) = encode(lmap(x), es)
encode(x::IdentityLM, es::AbstractVector{EdgeID}) = es

function encode(x::DictLM, es::AbstractVector{EdgeID})
   [encode(x, e) for e in es]
end

################################################# ADDVERTEX ################################################################

###
# WITHOUT LABEL
###
addvertex!(x::LabelModule) = addvertex!(lmap(x))

function addvertex!(x::IdentityLM)
   x.nv += 1
end

addvertex!(x::DictLM) = error("Please supply a label")

###
# WITH LABEL
###
function addvertex!(x::LabelModule, l)
   if haslabel(x, l)
      resolve(x, l)
   else
      x.lmap = addvertex!(lmap(x), l)
      nv(x)
   end
end

addvertex!(x::IdentityLM, l) = addvertex!(DictLM(x), l)

function addvertex!{T}(x::DictLM{T}, l::T)
   push!(rmap(x), l)
   fmap(x)[l] = (x.nv += 1)
   x
end

addvertex!(x::DictLM, l) = addvertex!(type_promote(x, l), l)

################################################# RMVERTEX ###################################################################

rmvertex!(x::LabelModule, vs) = rmvertex!(lmap(x), vs)

function rmvertex!(x::IdentityLM, vs)
   x.nv -= length(vs)
end

function rmvertex!(x::DictLM, vs)
   fm = fmap(x)
   rm = rmap(x)
   broadcast(delete!, [fm], vs)
   deleteat!(rm, vs)
   for v in minimum(vs) : length(rm)
      fmap(x)[rm[v]] = v
   end
   x.nv -= length(vs)
   nothing
end

################################################# SUBGRAPH ####################################################################

subgraph(x::LabelModule, vlist::AbstractVector{VertexID}) = LabelModule(subgraph(lmap(x), vlist))
subgraph(x::LabelModule, elist::AbstractVector{EdgeID}) = x

subgraph(x::IdentityLM, vlist::AbstractVector{VertexID}) = IdentityLM(length(vlist))

function subgraph(x::DictLM, vlist::AbstractVector{VertexID})
   DictLM(rmap(x)[vlist])
end
