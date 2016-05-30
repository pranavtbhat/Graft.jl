################################################# FILE DESCRIPTION #########################################################

# This file contains package wide type aliases, constants, macros, utility methods, etc.

################################################# IMPORT/EXPORT ############################################################

export 
# Type Aliases
VertexID, EdgeID, PropID, SparseArray


################################################# TYPE ALIASES #############################################################

""" Datatype used to store vertex id numbers """
typealias VertexID Int

""" Datatype used to store edge id numbers. (Change to Int128 if necessary) """
typealias EdgeID Int

""" Datatype used to store property indices """
typealias PropID Int

""" Datatype of keys in properties """
typealias PropName AbstractString

""" Data structure used in SparseGraphs """
typealias SparseArray NDSparse{Void,2,Tuple{Int64,Int64,Int64},Tuple{Array{Int64,1},Array{Int64,1},Array{Int64,1}},Array{Any,1}} 
################################################# CONSTANTS    #############################################################

""" Maximum number of vertices supported """
const MAX_VERTEX = typemax(VertexID)

""" Maximum number of edges supported """
const MAX_EDGE = typemax(EdgeID)

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