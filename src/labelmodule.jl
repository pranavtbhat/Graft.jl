################################################# FILE DESCRIPTION #########################################################

# ParallelGraphs allows users to refer to vertices externally, through arbitrary Julia types. The LabelModule is responsible
# for the resolution of these arbitrary objects into the internally used Integer indices. Both forward and reverse mappings
# are stored in the same Dict.

################################################# IMPORT/EXPORT ############################################################
export
# Types
LabelModule,
# Implementation
setlabel!, resolve, encode

type LabelModule{T}
   nv::Int
   fmap::Dict{T,VertexID}
   rmap::Vector{T}
end

function LabelModule{T}(nv, labels::Vector{T})
   nv != length(labels) && error("Number of labels should equal number of vertices")
   LabelModule{T}(nv, [label=>i for (i,label) in enumerate(labels)], labels)
end

@inline nv(x::LabelModule) = x.nv
@inline fmap(x::LabelModule) = x.fmap
@inline rmap(x::LabelModule) = x.rmap

################################################# API ######################################################################

function setlabel!(x::LabelModule, v::VertexID, label)
   fmap(x)[label] = v
   rmap(x)[v] = label
   nothing
end

function setlabel!(x::LabelModule, vs::AbstractVector{VertexID}, ls::AbstractVector)
   for (v,label) in zip(vs,ls)
      fmap(x)[label] = v
      rmap(x)[v] = label
   end
end



function resolve(x::LabelModule, label)
   haskey(fmap(x), label) || error("Input Vertex identifier $label couldn't be resolved")
   fmap(x)[label]
end
@inline resolve(x::LabelModule, ls::AbstractVector) = map(l->resolve(x, l), ls)

function resolve(x::LabelModule, ul, vl)
   EdgeID(resolve(x, ul), resolve(x, vl))
end
@inline resolve(x::LabelModule, es::AbstractVector{Pair}) = map(e->resolve(x, e...), es)



haslabel(x::LabelModule, y) = haskey(fmap(x), y)



function encode(x::LabelModule, v::VertexID)
   isdefined(rmap(x), v) || error("$v hasn't been assigned a label")
   rmap(x)[v]
end
@inline encode(x::LabelModule, vs::AbstractVector{VertexID}) = map(v->encode(x, v), vs)

function encode{T}(x::LabelModule{T}, e::EdgeID)
   Pair{T,T}(encode(x, e.first), encode(x, e.second))
end
@inline encode(x::LabelModule, es::AbstractVector{EdgeID}) = map(e->encode(x, e), es)



function addvertex!(x::LabelModule, num::Int=1)
   resize!(rmap(x), nv(x) + num)
   x.nv += num
   nothing
end

function rmvertex!(x::LabelModule, vs)
   fm = fmap(x)
   rm = rmap(x)

   for v in vs
      delete!(fm, rm[v])
   end

   deleteat!(rm, vs)

   for v in minimum(vs) : length(rm)
      fmap(x)[rm[v]] = v
   end



   x.nv -= length(vs)
   nothing
end

function subgraph{T}(x::LabelModule{T}, vlist::AbstractVector{VertexID})
   LabelModule(length(vlist), rmap(x)[vlist])
end

subgraph(x::LabelModule, elist::AbstractVector{EdgeID}) = x
