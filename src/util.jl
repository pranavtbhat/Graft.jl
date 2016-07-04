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

# Delete an entry(s) from a sparsematrix. Based on setindex from Julia's SparseMatrixCSC
function delete_entry!{Tv,Ti}(x::SparseMatrixCSC{Tv,Ti}, i::Int, j::Int)
   rowval = x.rowval
   nzval = x.nzval
   colptr = x.colptr

   r1 = Int(colptr[i])
   r2 = Int(colptr[i+1]-1)

   if r1 <= r2
      r1 = searchsortedfirst(rowval, j, r1, r2, Base.Order.Forward)
      if (r1 <= r2) && (rowval[r1] == j)
         deleteat!(rowval, r1)
         deleteat!(nzval, r1)
         @simd for k = (i+1):(x.n+1)
            @inbounds colptr[k] -= 1
         end
      end
   end
end

function delete_entry!{Tv,Ti}(x::SparseMatrixCSC{Tv,Ti}, i::Int, ::Colon)
   rowval = x.rowval
   nzval = x.nzval
   colptr = x.colptr

   r1 = Int(colptr[i])
   r2 = Int(colptr[i+1]-1)

   if r1 <= r2
      r = r1 : r2
      deletat!(rowval, r)
      deletat!(nzval, r)
      @simd for k = (i+1):(x.n+1)
         @inbounds colptr[k] -= length(r)
      end
   end
end



# Remove columns from a sparsematrix
function remove_cols{Tv,Ti}(x::SparseMatrixCSC{Tv,Ti}, vs::Union{Int,AbstractVector{Int}})
   vlist = collect(1 : x.m)
   deleteat!(vlist, vs)
   x[vlist,vlist]
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

################################################# REPL DISPLAY ################################################################

function printval(io::IO, len::Int, x)
   s = string(x)
   if length(s) > 15
      @printf "%-15s...  " join(s[1:15])
   else
      @printf "%-20s" s
   end
end

drawhl(io::IO, len) = print(io, join(fill('\u2500', len)))
drawvl(io::IO) = print(io, "\u2502")

drawljunc(io::IO) = print(io, "\u251c")
drawrjunc(io::IO) = print(io, "\u2524")
drawtjunc(io::IO) = print(io, "\u252c")
drawmjunc(io::IO) = print(io, "\u253c")
drawbjunc(io::IO) = print(io, "\u2534")

drawtlcorner(io::IO) = print(io, "\u250c")
drawtrcorner(io::IO) = print(io, "\u2510")

drawbrcorner(io::IO) = print(io, "\u2518")
drawblcorner(io::IO) = print(io, "\u2514")

drawboxhl(io::IO, len) = drawhl(io, len+2)

function drawbox(io::IO, rows)
   propcols = length(rows[1]) - 1
   n = length(rows)

   # Top
   drawtlcorner(io)
   drawhl(io, 20)
   for i in 1:propcols
      drawtjunc(io)
      drawhl(io, 20)
   end
   drawtrcorner(io)

   for row in rows
      println(io)
      drawvl(io)
      printval(io, 20, row[1])
      for val in row[2:end]
         drawvl(io)
         printval(io, 20, val)
      end
      drawvl(io)

      if row == rows[end]
         continue
      end
      # HLINE
      println(io)
      drawljunc(io)
      drawhl(io, 20)
      for val in row[2:end]
         drawmjunc(io)
         drawhl(io, 20)
      end
      drawrjunc(io)
   end

   println(io)

   # Bottom
   drawblcorner(io)
   drawhl(io, 20)
   for i in 1:propcols
      drawbjunc(io)
      drawhl(io, 20)
   end
   drawbrcorner(io)

   println(io)
end
