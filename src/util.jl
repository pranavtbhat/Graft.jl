################################################# FILE DESCRIPTION #########################################################

# This file contains package wide type aliases, constants, macros, utility methods, etc.

################################################# IMPORT/EXPORT ############################################################

export
# Types
FakeVector,
# Type Aliases
Edge, VertexID, EdgeID, PropID,
# Constants
MAX_VERTEX, MAX_EDGE, MAX_GRAPH_SIZE

################################################# TYPE ALIASES #############################################################

""" Datatype used to store vertex id numbers """
typealias VertexID Int

""" Datatype used to store edges """
typealias EdgeID Pair{VertexID,VertexID}

################################################# CONSTANTS ################################################################

""" Maximum number of vertices supported """
const MAX_VERTEX = typemax(Int)

""" Maximum number of edges supported """
const MAX_EDGE = typemax(Int)

const MAX_GRAPH_SIZE = (10^8,10^8)

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



################################################# MACROS ###################################################################

getvarname(x::Expr) = x.args[1]
getvarname(x::Symbol) = x

"""
Declare that a function definition is an interface declaration. If multiple dispatch fails to find a more specialized
method, then throw a method undefinded error.
Borrowed from ComputeFramework.
"""
macro interface(expr)
    @assert expr.head == :call

    fname = expr.args[1]
    args = expr.args[2:end]
    sig = string(expr)

    vars = map(x->getvarname(x), args)
    typs = Expr(:vect, map(x -> :(typeof($x)), vars)...)


    :(function $(esc(fname))($(args...))
        error(string("The method ", $sig, " hasn't been implemented on ", ($typs[1])))
    end)
end
