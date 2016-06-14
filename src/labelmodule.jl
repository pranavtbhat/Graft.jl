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
   fmap::Dict{T,VertexID}
   rmap::Vector{T}
end

function LabelModule{T}(labels::Vector{T})
   LabelModule{T}([label=>i for (i,label) in enumerate(labels)], copy(labels))
end

@inline fmap(x::LabelModule) = x.fmap
@inline rmap(x::LabelModule) = x.rmap

################################################# API ######################################################################

function setlabel!{T}(x::LabelModule{T}, v::VertexID, label::T)
   fmap(x)[label] = v
   rmap(x)[v] = label
   nothing
end

function resolve{T}(x::LabelModule{T}, label::T)
   haskey(fmap(x), label) || error("Input Vertex identifier $label couldn't be resolved")
   fmap(x)[label]
end

function resolve{T}(x::LabelModule{T}, e::Pair)
   D = fmap(x)
   (haskey(D, e.first) && haskey(D, e.second)) || error("Input Vertex identifier $label couldn't be resolved")
   Pair{T,T}(D[e.first], D[e.second])
end

@inline encode{T}(x::LabelModule{T}, v::VertexID) = rmap(x)[v]


function subgraph{T}(x::LabelModule{T}, vlist::AbstractVector{VertexID})
   new_labels = rmap(x)[vlist]
   LabelModule(new_labels)
end

subgraph{T}(x::LabelModule{T}, elist::Vector) = x