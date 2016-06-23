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
   rmap::Dict{VertexID,T}
end

function LabelModule()
   LabelModule{Any}(Dict(), Dict())
end

function LabelModule{T}(labels::Vector{T})
   LabelModule{T}([label=>i for (i,label) in enumerate(labels)], [i=>label for (i,label) in enumerate(labels)])
end

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

function resolve(x::LabelModule, e::Pair)
   EdgeID(resolve(x, e.first), resolve(x, e.second))
end
@inline resolve(x::LabelModule, es::AbstractVector{Pair}) = map(e->resolve(x, e), es)



function encode(x::LabelModule, v::VertexID)
   haskey(rmap(x), v) || error("Input Vertex identifier $label couldn't be resolved")
   rmap(x)[v]
end
@inline encode(x::LabelModule, vs::AbstractVector{VertexID}) = map(v->encode(x, v), vs)

function encode{T}(x::LabelModule{T}, e::EdgeID)
   Pair{T,T}(encode(x, e.first), encode(x, e.second))
end
@inline encode(x::LabelModule, es::AbstractVector{EdgeID}) = map(e->encode(x, e), es)



addvertex!(x::LabelModule, num::Int=1) = nothing

function rmvertex!(x::LabelModule, vs)
   for v in vs
      label = rmpa(x)[v]
      delete!(fmap(x), label)
      delete!(rmap(x), v)
   end
end




function subgraph(x::LabelModule, vlist::AbstractVector{VertexID})
   new_labels = [rmap(x)[v] for v in vlist]
   LabelModule(new_labels)
end

subgraph(x::LabelModule, elist::AbstractVector{EdgeID}) = x