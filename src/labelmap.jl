################################################# FILE DESCRIPTION #########################################################

# Graft allows users to refer to vertices externally, through arbitrary Julia types. The LabelMap is responsible
# for the resolution of these arbitrary objects into the internally used Integer indices.

# The label map is the datastructure that is used to realize two separate labelling schemes:
# 1. By default, vertices don't have labels, and are referred to by their internally used integer indices.
#    The IdentityLM type is used in this case. This labelling scheme is similar to the one used in LightGraphs.jl
#    and is confusing to use when vertices are removed etc. Sometimes its very inconvenient to think of vertices
#    as numbers! However this scheme incurs no performance overhead in label resolution.
#
# 2. Once the user assigns labels to all vertices, the DictLM datastructure is used to accomplish forward and
#    reverse translations. While both translations are done in constant time, a user defined vertex labelling
#    scheme can incur significant overheads in label translations, especially in large graphs.
#
# Since the type of the map can change depending on the nature of the operation, the modified label map is returned.
# Most label operations should therefore be called as:
# g.lmap = mutate!(g.lmap)

################################################# IMPORT/EXPORT #######################################################

export
# Types
setlabel!, relabel!, haslabel, decode, encode

"""
A type that forward maps labels into internally used vertex identifiers,
and reverse maps vertex identifiers into labels.
"""
abstract LabelMap{T}

################################################# CONSTRUCTORS ########################################################

LabelMap(nv::Int) = IdentityLM(nv)

LabelMap{T}(ls::Vector{T}) = DictLM(ls)

################################################# IDENTITYLM ##########################################################

"""
The default label map, that indicates the absence of meaningful vertex labels.
The usage of this type incurs zero overhead in label resolution.

Since vertices are referred to by their internally used indices, the usage
of this labelling scheme can be problematic when vertices are deleted.
"""
type IdentityLM <: LabelMap{Int}
   nv::Int
end

nv(x::IdentityLM) = x.nv

################################################# DICTLM ##############################################################

"""
This label map is used when vertices are assigned meaningful labels. This type uses
a dictionary to map labels onto vertex identifies, and a vector to map vertex
identifiers onto labels.

Labels can be of any user defined type.
"""
type DictLM{T} <: LabelMap{T}
   nv::Int
   fmap::Dict{T,VertexID}
   rmap::Vector{T}
end

""" Construct a label map from a list of labels """
function DictLM{T}(labels::AbstractVector{T})
   nv = length(labels)
   fmap = Dict(l => i for (i,l) in enumerate(labels))
   return DictLM{T}(nv, fmap, copy(labels))
end

"""
Construct a label map from the internally used vertex identifiers.
"""
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
(==)(x::LabelMap, y::LabelMap) = encode(x) == encode(y)


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

""" Remove vertex labels """
setlabel!(x::LabelMap) = IdentityLM(x.nv)


""" Set new labels for all vertices """
setlabel!(x::IdentityLM, ls::AbstractVector) = DictLM(ls)
setlabel!(x::DictLM, ls::AbstractVector) = DictLM(ls)

################################################# RELABEL SINGLE ######################################################

""" Change the label of a single vertex """
relabel!(x::IdentityLM, v::VertexID, l) = relabel!(DictLM(x), v, l)

function relabel!{T}(x::DictLM{T}, v::VertexID, l)
   l = convert(T, l)
   fmap(x)[l] = v
   rmap(x)[v] = l
   return x
end

################################################# RELABEL MUTLI #######################################################

""" Change labels for a list of vertices """
relabel!(x::IdentityLM, vs::VertexList, ls::AbstractVector) = relabel!(DictLM(x), vs, ls)

function relabel!{T}(x::DictLM{T}, vs::VertexList, ls::AbstractVector)
   ls = collect(T, ls)
   D = fmap(x)
   for i in eachindex(vs, ls)
      D[ls[i]] = vs[i]
   end
   rmap(x)[vs] = ls
   return x
end

################################################# HASLABEL ############################################################

""" Check if the input vertex label is valid """
haslabel(x::IdentityLM, v::VertexID) = 1 <= v <= nv(x)
haslabel(x::IdentityLM, l) = false

haslabel(x::DictLM, l) = haskey(fmap(x), l)

################################################# DECODE VERTEX #######################################################
""" Translate a vertex label into the internally used vertex identifier """
decode(x::IdentityLM, v::VertexID) = 1 <= v <= nv(x) ? v : error("Couldn't decode vertex label $v")

decode(x::IdentityLM, l) = error("Couldn't decode vertex label $l")

function decode(x::DictLM, l)
   get(fmap(x), l) do
      error("Couldn't decode vertex label $l")
   end
end

################################################# DECODE VERTICES ##########################################################

""" Translate a list of labels into the internally used vertex identifiers """
decode(x::IdentityLM, vs::VertexList) = vs
decode(x::DictLM, ls::AbstractVector) = [decode(x, l) for l in ls]

################################################# DECODE EDGE ##############################################################

""" Decode both vertices in a labelled edge """
decode(x::IdentityLM, e::EdgeID) = e
decode(x::DictLM, el::Pair) = EdgeID(decode(x, el.first), decode(x, el.second))

################################################# ENCODE VERTEX ############################################################

""" Map the input vertex identifier into the externally used label """
encode(x::IdentityLM, v::VertexID) = v
encode(x::DictLM, v::VertexID) = getindex(rmap(x), v)

################################################# ENCODE VERTICES ##########################################################

""" Map the input vertex identifier into its externally used label """
encode(x::IdentityLM, vs::VertexList) = collect(vs)
encode(x::DictLM, vs::VertexList) = getindex(rmap(x), vs)

################################################# FETCH ALL LABELS #########################################################

""" Map the input list of vertex identifiers into their externally used labels """
encode(x::IdentityLM) = collect(1 : x.nv)
encode(x::DictLM) = copy(rmap(x))

################################################# ENCODE EDGE ##############################################################

""" Encode both vertices in an edge identifier """
encode(x::IdentityLM, e::EdgeID) = e
encode{T}(x::DictLM{T}, e::EdgeID) = Pair{T,T}(encode(x, e.first), encode(x, e.second))

################################################# ENCODE EDGES #############################################################

""" Encode all edges in an input edge list """
encode(x::IdentityLM, es::EdgeList) = es

encode(x::DictLM, es::EdgeList) = [encode(x, e) for e in es]

################################################# ADDVERTEX ################################################################

"""
Add an unlabelled vertex to the graph. This method throws
an error, when used on a labelled graph.
"""
function addvertex!(x::IdentityLM)
   x.nv += 1
   return x
end

addvertex!(x::DictLM) = error("Please supply a label")

"""
Add a labelled vertex to the graph. If used on an
unlabelled graph, this method will assign the internally
used vertex identifiers as labels to existing vertices.
"""
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

""" Remove a list of vertices from the graph. """
function rmvertex!(x::IdentityLM, vs)
   x.nv -= length(vs)
   return x
end

function rmvertex!(x::DictLM, vs)
   F = fmap(x)
   R = rmap(x)

   ls = encode(x, vs)

   # Remove labels from Forward map
   for l in ls
      delete!(F, l)
   end

   # Remove labels from Reverse map
   deleteat!(R, vs)

   # Redirect labels in Forward map to new indexes
   for v in minimum(vs) : length(R)
      F[R[v]] = v
   end

   # Decrement Label Map size
   x.nv -= length(vs)

   return x
end

################################################# SUBGRAPH ####################################################################

""" Retrieve a subset of vertex labels """
subgraph(x::IdentityLM, vlist::VertexList) = IdentityLM(length(vlist))

function subgraph(x::DictLM, vlist::VertexList)
   DictLM(rmap(x)[vlist])
end
