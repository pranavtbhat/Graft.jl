################################################# FILE DESCRIPTION #########################################################

# This file contains the SparseMatrixAM adjacency module, as well as an implementation of the AdjacencyModule interface.
 
################################################# IMPORT/EXPORT ############################################################
export
SparseMatrixAM, VertexIteratorCSC

type SparseMatrixAM <: AdjacencyModule
   nv::Int
   ne::Int
   fdata::SparseMatrixCSC{Bool, Int}
   rdata::SparseMatrixCSC{Bool, Int}
end


################################################# GENERATORS ###############################################################

function SparseMatrixAM(nv=0)
   fdata = spzeros(Bool, nv, nv)
   rdata = spzeros(Bool, nv, nv)
   SparseMatrixAM(nv, 0, fdata, rdata)
end

function SparseMatrixAM(nv::Int, ne::Int)
   m = sprandbool(nv, nv, ne/(nv*nv))
   fdata = triu(m,1) | tril(m,-1)
   rdata = fdata'
   SparseMatrixAM(nv, nnz(fdata), fdata, rdata)
end

################################################# ACCESSORS ################################################################

@inline fdata(x::SparseMatrixAM) = x.fdata

@inline rdata(x::SparseMatrixAM) = x.rdata

################################################# INTERNAL IMPLEMENTATION ##################################################

type EdgeIteratorCSC
   am::SparseMatrixAM
end

Base.length(x::EdgeIteratorCSC) = x.am.ne
Base.start(x::EdgeIteratorCSC) = (1, 1, 1)
Base.done(x::EdgeIteratorCSC, t) = t[3] > nnz(x.am.fdata)

function Base.show(io::IO, x::EdgeIteratorCSC)
   write(io, "Edge Iterator with $(x.am.ne) values")
end

function Base.next(x::EdgeIteratorCSC, t)
   m = x.am.fdata
   u, vi, e = t
   if vi in nzrange(m, u)
      return (u => m.rowval[vi]), (u, vi+1, e+1)
   else
      u += 1
      while u < x.am.nv && length(nzrange(m, u)) == 0
         u += 1
      end
      vi = start(nzrange(m, u))
      return (u=>m.rowval[vi]), (u, vi+1, e+1)
   end
end

Base.collect(x::EdgeIteratorCSC) = Pair{VertexID,VertexID}[e for e in x]

# Since SparseMatrixCSC maintains a colptr field, equal to the size of the matrix, arbitrarily high sizes cannot be 
# maintained. Therefore, the SparseMatrix must grow, for each vertex added. Maybe a more sophisticated approach (like
# binary probing) can reduce the amortized allocation count?
function grow(x::SparseMatrixCSC{Bool,Int}, sz::Int)
   colptr = x.colptr
   SparseMatrixCSC{Bool,Int}(x.m+sz, x.n+sz, append!(colptr, fill(colptr[end], sz)), x.rowval, x.nzval)
end

# No shrink required as of now.

################################################# INTERFACE IMPLEMENTATION ##################################################

nv(x::SparseMatrixAM) = x.nv

ne(x::SparseMatrixAM) = x.ne

Base.size(x::SparseMatrixAM) = (x.nv, x.ne)

@inline vertices(x::SparseMatrixAM) = UnitRange{Int}(1, nv(x))

@inline edges(x::SparseMatrixAM) = EdgeIteratorCSC(x)

function fadj(x::SparseMatrixAM, v::Int)
   M = fdata(x)
   M.rowval[nzrange(M, v)]
end

function badj(x::SparseMatrixAM, v::Int)
   M = rdata(x)
   M.rowval[nzrange(M, v)]
end

hasedge(x::SparseMatrixAM, u::VertexID, v::VertexID) = fdata(x)[u,v]

function addvertex!(x::SparseMatrixAM, numv::Int = 1)
   x.fdata = grow(fdata(x), numv)
   x.rdata = grow(rdata(x), numv)
   x.nv += numv
   nothing
end

# Does not remove the vertex, simply deletes all the edges attached to it.
function rmvertex!(x::SparseMatrixAM, v::Int)
   setindex!(fdata(x), false, v, :)
   setindex!(fdata(x), false, :, v)
   setindex!(rdata(x), false, :, v)
   setindex!(rdata(x), false, v, :)
   nothing
end

function addedge!(x::SparseMatrixAM, u::Int, v::Int)
   x.ne += 1
   fdata(x)[v,u] = true
   rdata(x)[u,v] = true
   nothing
end

function rmedge!(x::SparseMatrixAM, u::Int, v::Int)
   x.ne -= 1
   fdata(x)[v,u] = false
   rdata(x)[u,v] = false
   nothing
end

################################################# SUBGRAPH #####################################################################

function subgraph(x::SparseMatrixAM, vlist::AbstractVector{VertexID})
   vlen = length(vlist)
   M = fdata(x)[vlist,vlist]
   SparseMatrixAM(length(vlist), nnz(M), M, M')
end

function subgraph{I<:Integer}(x::SparseMatrixAM, elist::Vector{Pair{I,I}})
   M = spzeros(size(fdata(x))...)
   for e in elist
      M[e.second,e.first] = true
   end
   SparseMatrixAM(nv(x), nnz(M), M, M')
end

