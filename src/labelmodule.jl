################################################# FILE DESCRIPTION #########################################################

# ParallelGraphs allows users to refer to vertices externally, through arbitrary Julia types. The LabelMap is responsible
# for the resolution of these arbitrary objects into the internally used Integer indices.

################################################# IMPORT/EXPORT #######################################################

export
# Types
LabelMap,
# LabelMaps
IdentityLM, DictLM,
# Implementation
setlabel!, relabel!, haslabel, decode, encode

abstract LabelMap{T}

################################################# CONSTRUCTORS ########################################################

LabelMap(nv::Int) = IdentityLM(nv)

LabelMap{T}(ls::Vector{T}) = DictLM(ls)

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
   return DictLM{T}(nv, fmap, copy(labels))
end

# Convert from IdentityLM
DictLM(x::IdentityLM) = DictLM([i for i in 1 : nv(x)])


# Accessors
nv(x::DictLM) = x.nv
fmap(x::DictLM) = x.fmap
rmap(x::DictLM) = x.rmap

################################################# MSC ################################################################

###
# ELTYPE
###
Base.eltype(x::IdentityLM) = Int
Base.eltype{T}(x::DictLM{T}) = T


###
# ==
###
(==)(x::IdentityLM, y::IdentityLM) = encode(x) == encode(y)


###
# COPY
###
Base.copy(x::IdentityLM) = IdentityLM(nv(x))
Base.copy(x::DictLM) = DictLM(nv(x), copy(fmap(x)), copy(rmap(x)))


###
# DEEPCOPY
###
Base.deepcopy(x::IdentityLM) = IdentityLM(nv(x))
Base.deepcopy(x::DictLM) = DictLM(nv(x), deepcopy(fmap(x)), deepcopy(rmap(x)))

################################################# SETLABEL ############################################################

###
# REMOVE LABELS
###
setlabel!(x::LabelMap) = IdentityLM(x.nv)


###
# SET NEW LABELS
###
setlabel!(x::IdentityLM, ls::AbstractVector) = DictLM(ls)
setlabel!(x::DictLM, ls::AbstractVector) = DictLM(ls)

################################################# RELABEL SINGLE ######################################################

relabel!(x::IdentityLM, v::VertexID, l) = setlabel!(DictLM(x), v, l)

function relabel!{T}(x::DictLM{T}, v::VertexID, l)
   l = convert(T, l)
   fmap(x)[l] = v
   rmap(x)[v] = l
   return x
end

################################################# RELABEL MUTLI #######################################################

setlabel!(x::IdentityLM, vs::VertexList, ls::AbstractVector) = setlabel!(DictLM(x), vs, ls)

function setlabel!{T}(x::DictLM{T}, vs::VertexList, ls::AbstractVector)
   ls = collect(T, ls)
   D = fmap(x)
   for i in eachindex(vs, ls)
      D[ls[i]] = vs[i]
   end
   rmap(x)[vs] = ls
   return x
end

################################################# HASLABEL ############################################################

haslabel(x::IdentityLM, v::VertexID) = 1 <= v <= nv(x)
haslabel(x::IdentityLM, l) = false

haslabel(x::DictLM, l) = haskey(fmap(x), l)

################################################# DECODE VERTEX #######################################################

decode(x::IdentityLM, v::VertexID) = v
decode(x::IdentityLM, l) = error("Couldn't decode vertex label $l")

function decode(x::DictLM, l)
   get(fmap(x), l) do
      error("Couldn't decode vertex label $l")
   end
end

################################################# DECODE VERTICES ##########################################################

decode(x::IdentityLM, vs::VertexList) = vs
decode(x::DictLM, ls::AbstractVector) = [decode(x, l) for l in ls]

################################################# DECODE EDGE ##############################################################

decode(x::IdentityLM, e::EdgeID) = e
decode(x::DictLM, el::Pair) = EdgeID(decode(x, el.first), decode(x, el.second))

################################################# ENCODE VERTEX ############################################################

encode(x::IdentityLM, v::VertexID) = v
encode(x::DictLM, v::VertexID) = getindex(rmap(x), v)

################################################# ENCODE VERTICES ##########################################################

encode(x::IdentityLM, vs::VertexList) = vs
encode(x::DictLM, vs::VertexList) = getindex(rmap(x), vs)

################################################# ENCODE EDGE ##############################################################

encode(x::IdentityLM, e::EdgeID) = e
encode{T}(x::DictLM{T}, e::EdgeID) = Pair{T,T}(encode(x, e.first), encode(x, e.second))

################################################# ENCODE EDGES #############################################################

encode(x::IdentityLM, es::EdgeList) = es

encode(x::DictLM, es::EdgeList) = [encode(x, e) for e in es]

################################################# ADDVERTEX ################################################################

###
# WITHOUT LABEL
###
function addvertex!(x::IdentityLM)
   x.nv += 1
   return x
end

addvertex!(x::DictLM) = error("Please supply a label")

###
# WITH LABEL
###
function addvertex!(x::IdentityLM, l)
   if l == nv(x) + 1
      addvertex!(x)
   else
      addvertex!(DictLM(x), l)
   end
end

function addvertex!{T}(x::DictLM{T}, l)
   l = convert(T, l)
   x.nv += 1
   push!(rmap(x), l)
   fmap(x)[l] = nv(x)
   return x
end

################################################# RMVERTEX ###################################################################

function rmvertex!(x::IdentityLM, vs)
   x.nv -= length(vs)
   return x
end

function rmvertex!(x::DictLM, vs)
   ls = encode(x, vs)
   for l in ls
      delete!(fmap(x), l)
   end
   deleteat!(rm, vs)
   for v in minimum(vs) : length(rm)
      fmap(x)[rm[v]] = v
   end
   x.nv -= length(vs)
   return x
end

################################################# SUBGRAPH ####################################################################

subgraph(x::IdentityLM, vlist::VertexList) = IdentityLM(length(vlist))

function subgraph(x::DictLM, vlist::VertexList)
   DictLM(rmap(x)[vlist])
end
