################################################# FILE DESCRIPTION #########################################################

# This file contains package wide type aliases, constants, macros, utility methods, etc.

################################################# IMPORT/EXPORT ############################################################

export
# Types
NullModule, CustomIterator,
# Type Aliases
Edge, VertexID, EdgeID, PropID, SparseArray,
# SparseMatrixCSC
remove_cols, grow, init_spmx,
# Macros
redirect,
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

################################################# NULL MODULE ##############################################################

""" Null property module. Does not implement any interface. To be used as a dummy. """

immutable NullModule
end

NullModule(args...) = NullModule()

# Adjacency
nv(x::NullModule) = Void()
ne(x::NullModule) = Void()
Base.size(x::NullModule) = Void()
vertices(x::NullModule) = Void()
edges(x::NullModule, args...) = Void()
hasedge(x::NullModule, args...) = Void()
fadj(x::NullModule, args...) = Void()
badj(x::NullModule, args...) = Void()
addvertex!(x::NullModule, args...) = Void()
rmvertex!(x::NullModule, args...) = Void()
addedge!(x::NullModule, args...) = Void()
rmedge!(x::NullModule, args...) = Void()

# Properties
listvprops(x::NullModule) = Void()
listeprops(x::NullModule) = Void()
getvprop(x::NullModule, v::VertexID) = Void()
getvprop(x::NullModule, v::VertexID, propname) = Void()
geteprop(x::NullModule, u::VertexID, v::VertexID) = Void()
geteprop(x::NullModule, u::VertexID, v::VertexID, propname) = Void()
setvprop!(x::NullModule, v::VertexID, props::Dict) = Void()
setvprop!(x::NullModule, v::VertexID, propname, val) = Void()
seteprop!(x::NullModule, u::VertexID, v::VertexID, props::Dict) = Void()
seteprop!(x::NullModule, u::VertexID, v::VertexID, propname, val) = Void()

# Labelling
setlabel!(x::NullModule, v::VertexID, obj) = Void()
resolve(x::NullModule, obj) = obj
encode(x::NullModule, obj) = obj

# Subgraphing
subgraph(x::NullModule, args...) = x

################################################# SPARSEMATRIXCSC ##########################################################

# Remove columns from a sparsematrix
function remove_cols{Tv,Ti}(x::SparseMatrixCSC{Tv,Ti}, v::Union{Int,AbstractVector{Int}})
   setindex!(x, 0, v, :)
   setindex!(x, 0, :, v)
   setindex!(x, 0, :, v)
   setindex!(x, 0, v, :)

   m = x.m - length(v)
   SparseMatrixCSC{Tv,Ti}(m, m, deleteat!(x.colptr, v), x.rowval, x.nzval)
end

# Grow a sparsematrix along the diagonal
function grow{Tv,Ti}(x::SparseMatrixCSC{Tv,Ti}, sz::Int)
   colptr = x.colptr
   SparseMatrixCSC{Tv,Ti}(x.m+sz, x.n+sz, append!(colptr, fill(colptr[end], sz)), x.rowval, x.nzval)
end

# Construct a sparsematrix using a list of edges.
function init_spmx{Tv}(nv::Int, elist::Vector{EdgeID}, vals::Vector{Tv})
   nzval = vals
   rowval = map(x->x.second, elist)
   vlist = map(x->x.first, elist)
   len = length(vlist)

   colptr = Array{Int}(nv+1)
   i = 1
   colptr[1] = 1

   for c in 2 : nv
      i = searchsortedfirst(vlist, c, i+1, len, Base.Order.Forward)
      colptr[c] = i
   end

   colptr[nv+1] = len + 1

   SparseMatrixCSC{Tv,Int}(nv, nv, colptr, rowval, nzval)
end


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

################################################# UTILITIES ################################################################

""" Throw an error that the method isn't supported on the given type """
@inline function unsupported(t::DataType, fn::Function)
   error("Method $fn isn't supported on datatype $t")
end
