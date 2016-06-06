################################################# FILE DESCRIPTION #########################################################

# This file contains package wide type aliases, constants, macros, utility methods, etc.

################################################# IMPORT/EXPORT ############################################################

export 
# Type Aliases
VertexID, EdgeID, PropID, SparseArray,
# Macros
redirect,
# Constants
MAX_VERTEX, MAX_EDGE, MAX_GRAPH_SIZE

################################################# TYPE ALIASES #############################################################

""" Datatype used to store vertex id numbers """
typealias VertexID Int

""" Datatype used to store edge id numbers. (Change to Int128 if necessary) """
typealias EdgeID Int

""" Datatype used to store property indices """
typealias PropID Int

""" Data structure used in SparseGraphs """
typealias SparseArray NDSparse{Void,2,Tuple{Int64,Int64,Int64},Tuple{Array{Int64,1},Array{Int64,1},Array{Int64,1}},Array{Any,1}} 
################################################# CONSTANTS    #############################################################

""" Maximum number of vertices supported """
const MAX_VERTEX = typemax(Int)

""" Maximum number of edges supported """
const MAX_EDGE = typemax(Int)

const MAX_GRAPH_SIZE = (10^8,10^8)
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

# """
# Declare that a function is to be applied on one of the fields of the first argument, instead of the first argument 
# itself. Produces a kind of redirect.
# """
# macro redirect(expr, func)
#     @assert expr.head == :call

#     fname = expr.args[1]
#     f = length(fieldnames(fname)) > 0 ? fname.args[1] : fname

#     args = expr.args[2:end]

#     farg = args[1].args[1]

#     vars = map(x->getvarname(x), args)
#     typs = Expr(:vect, map(x -> :(typeof($x)), vars)...)

#     :(function $(esc(fname))($(args...))
#         $f($func($farg), $(vars[2:end]...))
#     end)
# end 

################################################# UTILITIES ################################################################

""" Throw an error that the method isn't supported on the given type """
@inline function unsupported(t::DataType, fn::Function)
   error("Method $fn isn't supported on datatype $t")
end

################################################# STACK ####################################################################

# Stack implementation suited to graph algorithms. Allocates memory once, and doesn't resize (to cut down on allocs).

type Stack
    n::Int
    top::Int
    data::Vector{Int}

    function Stack(n)
        self = new()
        self.n = n
        self.top = 0
        self.data = Array(Int, n)
        self
    end
end

@inline Base.isempty(s::Stack) = s.top == 0

@inline function Base.push!(s::Stack, item::Int)
    s.data[s.top+1] = item
    s.top += 1
    nothing
end

@inline function Base.push!(s::Stack, items::Vector{Int})
    len = length(items)
    s.data[(s.top+len):-1:(s.top+1)] = items
    s.top += len
    nothing
end

@inline function Base.pop!(s::Stack)
    val = s.data[s.top]
    s.top -= 1
    val
end

################################################# DEQUE  #####################################################################

# Deque implementation suited to graph algorithms. Allocates memory once, and doesn't resize (to cut down on allocs).

type Deque
    n::Int
    left::Int
    right::Int
    data::Vector{Int}

    function Deque(n)
        self = new()
        self.n = n
        self.left = 0
        self.right = 0
        self.data = Array(Int, n)
        self
    end
end

Base.isempty(d::Deque) = d.left == d.right

function Base.push!(d::Deque, item::Int)
    d.data[d.right+1] = item
    d.right += 1
    nothing
end

function Base.push!(d::Deque, items::Vector{Int})
    len = length(items)
    d.data[(d.right+1) : (d.right+len)] = items
    d.right += len
    nothing
end

function Base.shift!(d::Deque)
    val = d.data[d.left+1]
    d.left += 1
    val
end