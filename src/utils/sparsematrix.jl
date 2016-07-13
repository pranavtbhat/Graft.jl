################################################# FILE DESCRIPTION ##########################################################

# This file contains methods designed to adapt the SparseMatrixCSC datasturcture to graphs.

################################################# IMPORT/EXPORT ############################################################


################################################# DELETION ##################################################################

""" Delete an entry(s) from a sparsematrix. Based on setindex from Julia's SparseMatrixCSC """
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


""" Remove entire columns from a sparsematrix (return everything but those columns) """
function remove_cols{Tv,Ti}(x::SparseMatrixCSC{Tv,Ti}, vs::Union{Int,AbstractVector{Int}})
   vlist = collect(1 : x.m)
   deleteat!(vlist, vs)
   x[vlist,vlist]
end

################################################# EXPANSION ##################################################################

""" Grow a sparsematrix along the diagonal """
function grow{Tv,Ti}(x::SparseMatrixCSC{Tv,Ti}, sz::Int)
   colptr = x.colptr
   SparseMatrixCSC{Tv,Ti}(x.m+sz, x.n+sz, append!(colptr, fill(colptr[end], sz)), x.rowval, x.nzval)
end

################################################# GENERATION #################################################################

""" Construct a sparsematrix using a list of edges """
function init_spmx{Tv}(nv::Int, elist::Vector{EdgeID}, vals::Vector{Tv})
   nzval = vals
   m = length(elist)

   rowval = Array{Int}(m)
   vlist = Array{Int}(m)

   for i in 1 : m
      e = elist[i]
      vlist[i] = e.first
      rowval[i] = e.second
   end

   colptr = Array{Int}(nv+1)
   i = 0
   colptr[1] = 1

   for c in 2 : nv
      i = searchsortedfirst(vlist, c, i+1, m, Base.Order.Forward)
      colptr[c] = i
   end

   colptr[nv+1] = m + 1

   SparseMatrixCSC{Tv,Int}(nv, nv, colptr, rowval, nzval)
end

init_spmx(nv::Int, eit::AbstractVector{EdgeID}, vals::Vector) = init_spmx(nv, collect(eit), vals)
################################################# SPLICING ###################################################################

""" Pair-vector getindex for SparseMatrixCSC """
function splice_matrix{Tv,Ti}(x::SparseMatrixCSC{Tv,Ti}, elist::AbstractVector{EdgeID})
   m = length(elist)
   vals = Array{Tv}(m)
   for i in 1 : m
      u,v = elist[i]
      vals[i] = x[v,u]
   end

   init_spmx(x.m, elist, vals)
end

################################################# SIZEHINT ###################################################################

""" Sizehint to help sparsematrix grow quickly """
function Base.sizehint!(x::SparseMatrixCSC, ne::Int)
   sizehint!(x.rowval, ne)
   sizehint!(x.nzval, ne)
   x
end
