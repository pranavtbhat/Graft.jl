################################################# FILE DESCRIPTION #########################################################

# This file contains package wide type aliases, constants, macros, utility methods, etc.

################################################# IMPORT/EXPORT ############################################################

export
# Types
FakeVector,
# Type Aliases
VertexID, EdgeID, VertexList, EdgeList

################################################# TYPE ALIASES #############################################################

""" Datatype used to store vertex id numbers """
typealias VertexID Int

""" Datatype used to store edges """
typealias EdgeID Pair{VertexID,VertexID}

""" A list of Vertex IDs """
typealias VertexList AbstractVector{VertexID}

""" A list of Edge IDs """
typealias EdgeList AbstractVector{EdgeID}

################################################# FAKE VECTOR ##############################################################

""" A cunning alternative to fill when mutation isn't required """
type FakeVector{T} <: AbstractVector{T}
   val::T
   n::Int
end

# Size
Base.length(x::FakeVector) = x.n
Base.size(x::FakeVector) = (x.n,)

# Element type
Base.eltype{T}(x::FakeVector{T}) = T

# Iteration
Base.start(x::FakeVector) = 1
Base.next(x::FakeVector, i::Int) = (x.val, i+1)
Base.done(x::FakeVector, i::Int) = i > x.n
Base.endof(x::FakeVector) = x.n
Base.eachindex(x::FakeVector) = start(x) : endof(x)

# Getindex
Base.getindex(x::FakeVector, i::Int) = x.val
Base.getindex(x::FakeVector, is::AbstractVector{Int}) = FakeVector(x.n, length(is))
Base.getindex(x::FakeVector, ::Colon) = x

# Setindex!
Base.setindex!{T}(x::FakeVector{T}, args...) = error("Type FakeVector{$T} doesn't support setindex!")
