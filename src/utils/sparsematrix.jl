################################################# FILE DESCRIPTION ##########################################################
# This file contains methods designed to adapt the SparseMatrixCSC datasturcture to graphs.

################################################# IMPORT/EXPORT ############################################################


################################################# DELETION ##################################################################

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

################################################# EXPANSION ##################################################################

# Grow a sparsematrix along the diagonal
function grow{Tv,Ti}(x::SparseMatrixCSC{Tv,Ti}, sz::Int)
   colptr = x.colptr
   SparseMatrixCSC{Tv,Ti}(x.m+sz, x.n+sz, append!(colptr, fill(colptr[end], sz)), x.rowval, x.nzval)
end

################################################# GENERATION #################################################################
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
