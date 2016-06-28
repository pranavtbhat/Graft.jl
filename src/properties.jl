################################################# FILE DESCRIPTION #########################################################

# ParallelGraphs allows the assignment of properties (key-value pairs) the the edges and vertices in a graph. Property 
# modules are parameterized by a vertex template V and an edge template E. These templates must be types, where the fields
# and their types describe properties.

################################################# IMPORT/EXPORT ############################################################
export
# Types
PropertyModule,
# Properties Interface
listvprops, listeprops, getvprop, geteprop, setvprop!, seteprop!

abstract PropertyModule{V,E}

# Zeroing to help out with data storage
Base.zero(::Type) = nothing
Base.zero(::Type{Char}) = Char(0)
Base.zero{T<:AbstractString}(::Type{T}) = ""


################################################# INTERFACE ################################################################

@interface deepcopy{V,E}(x::PropertyModule{V,E})

@interface addvertex!{V,E}(x::PropertyModule{V,E}, num::Int=1)

@interface rmvertex!{V,E}(x::PropertyModule{V,E}, v)

@interface addedge!{V,E}(x::PropertyModule{V,E}, u::VertexID, v::VertexID)
@interface addedge!{V,E}(x::PropertyModule{V,E}, e::EdgeID)
@interface addedge!{V,E}(x::PropertyModule{V,E}, elist::AbstractVector{EdgeID})

@interface rmedge!{V,E}(x::PropertyModule{V,E}, u::VertexID, v::VertexID)
@interface rmedge!{V,E}(x::PropertyModule{V,E}, e::EdgeID)
@interface rmedge!{V,E}(x::PropertyModule{V,E}, elist::AbstractVector{EdgeID})

@interface listvprops{V,E}(x::PropertyModule{V,E})
@interface listeprops{V,E}(x::PropertyModule{V,E})

@interface getvprop{V,E}(x::PropertyModule{V,E}, v::VertexID)
@interface getvprop{V,E}(x::PropertyModule{V,E}, vlist::AbstractVector{VertexID})
@interface getvprop{V,E}(x::PropertyModule{V,E}, v::VertexID, propname)
@interface getvprop{V,E}(x::PropertyModule{V,E}, vlist::AbstractVector{VertexID}, propname)

@interface geteprop{V,E}(x::PropertyModule{V,E}, u::VertexID, v::VertexID)
@interface geteprop{V,E}(x::PropertyModule{V,E}, e::EdgeID)
@interface geteprop{V,E}(x::PropertyModule{V,E}, u::VertexID, v::VertexID, propname)
@interface geteprop{V,E}(x::PropertyModule{V,E}, e::EdgeID, propname)
@interface geteprop{V,E}(x::PropertyModule{V,E}, elist::AbstractVector{EdgeID})
@interface geteprop{V,E}(x::PropertyModule{V,E}, elist::AbstractVector{EdgeID}, propname)


@interface setvprop!{V,E}(x::PropertyModule{V,E}, v::VertexID, d::Dict)
@interface setvprop!{V,E}(x::PropertyModule{V,E}, vlist::AbstractVector{VertexID}, dlist::Vector)
@interface setvprop!{V,E}(x::PropertyModule{V,E}, v::VertexID, val, propname)
@interface setvprop!{V,E}(x::PropertyModule{V,E}, vlist::AbstractVector{VertexID}, vals::Vector, propname)
@interface setvprop!{V,E}(x::PropertyModule{V,E}, vlist::AbstractVector{VertexID}, f::Function, propname)
@interface setvprop!{V,E}(x::PropertyModule{V,E}, ::Colon, vals::Vector, propname)
@interface setvprop!{V,E}(x::PropertyModule{V,E}, ::Colon, f::Function, propname)


@interface seteprop!{V,E}(x::PropertyModule{V,E}, u::VertexID, v::VertexID, d::Dict)
@interface seteprop!{V,E}(x::PropertyModule{V,E}, e::EdgeID, d::Dict)
@interface seteprop!{V,E}(x::PropertyModule{V,E}, elist::AbstractVector{EdgeID}, dlist::Vector)
@interface seteprop!{V,E}(x::PropertyModule{V,E}, u::VertexID, v::VertexID, val, propname)
@interface seteprop!{V,E}(x::PropertyModule{V,E}, e::EdgeID, val, propname)
@interface seteprop!{V,E}(x::PropertyModule{V,E}, elist::AbstractVector{EdgeID}, vals::Vector, propname)
@interface seteprop!{V,E}(x::PropertyModule{V,E}, elist::AbstractVector{EdgeID}, f::Function, propname)
@interface seteprop!{V,E}(x::PropertyModule{V,E}, ::Colon, elist::AbstractVector{EdgeID}, vals::Vector, propname)
@interface seteprop!{V,E}(x::PropertyModule{V,E}, ::Colon, elist::AbstractVector{EdgeID}, f::Function, propname)

################################################# SUBGRAPHING ##############################################################

@interface subgraph{V,E}(x::PropertyModule{V,E}, vlist::AbstractVector{VertexID})

@interface subgraph{V,E}(x::PropertyModule{V,E}, elist::AbstractVector{EdgeID})

################################################# IMPLEMENTATIONS ##########################################################

# Sparse Implementation
include("propmods/sparsedict.jl")

# Dictionary-Array Implementation
include("propmods/dictarr.jl")

