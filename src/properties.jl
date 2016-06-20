################################################# FILE DESCRIPTION #########################################################

# ParallelGraphs allows the assignment of properties (key-value pairs) the the edges and vertices in a graph. The key can 
# be any arbitrary julia object, and therefore keys must be mapped on to integers, before they can be used to for indexing.
# The PropertyModule therefore stores values of type V, indexed by objects of type K.

################################################# IMPORT/EXPORT ############################################################
export
# Types
PropertyModule,
# Properties Interface
listvprops, listeprops, getvprop, geteprop, setvprop!, seteprop!

abstract PropertyModule{K,V}

# Zeroing to help out with data storage

Base.zero(::Type{ASCIIString}) = ""
Base.zero(::Type{Any}) = nothing

################################################# INTERFACE ################################################################

@interface addvertex!{K,V}(x::PropertyModule{K,V})
@interface rmvertex!{K,V}(x::PropertyModule{K,V}, v::VertexID)
@interface addedge!{K,V}(x::PropertyModule{K,V}, u::VertexID, v::VertexID)
@interface rmedge!{K,V}(x::PropertyModule{K,V}, u::VertexID, v::VertexID)

@interface listvprops{K,V}(x::PropertyModule{K,V})
@interface listeprops{K,V}(x::PropertyModule{K,V})

@interface getvprop{K,V}(x::PropertyModule{K,V}, v::VertexID)
@interface getvprop{K,V}(x::PropertyModule{K,V}, v::VertexID, propname)

@interface geteprop{K,V}(x::PropertyModule{K,V}, u::VertexID, v::VertexID)
@interface geteprop{K,V}(x::PropertyModule{K,V}, u::VertexID, v::VertexID, propname)

@interface setvprop!{K,V}(x::PropertyModule{K,V}, v::VertexID, props::Dict)
@interface setvprop!{K,V}(x::PropertyModule{K,V}, v::VertexID, propname, val)
@interface setvprop!{K,V}(x::PropertyModule{K,V}, vlist::AbstractVector, vals::Vector, propname)
@interface setvprop!{K,V}(x::PropertyModule{K,V}, vlist::AbstractVector, f::Function, propname)

@interface seteprop!{K,V}(x::PropertyModule{K,V}, u::VertexID, v::VertexID, props::Dict)
@interface seteprop!{K,V}(x::PropertyModule{K,V}, u::VertexID, v::VertexID, propname, val)
@interface seteprop!{K,V}(x::PropertyModule{K,V}, f::Function, propname, edges)

################################################# SUBGRAPHING ##############################################################

@interface subgraph{K,V}(x::PropertyModule{K,V}, vlist::AbstractVector{VertexID})

@interface subgraph{K,V,I<:Integer}(x::PropertyModule{K,V}, vlist::Vector{Pair{I,I}})

################################################# IMPLEMENTATIONS ##########################################################

# Sparse Implementation
include("sparse/sparsematrixpm.jl")

# NDSparse Implementation
include("ndsparse/propertymodule.jl")

# Pure Dict Implementation
include("dict/puredictpm.jl")

# Dictionary-Array Implementation
include("dict/dictarrpm.jl")
