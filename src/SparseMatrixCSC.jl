################################################# FILE DESCRIPTION ##########################################################

# This file contains graph compatibility methods for SparseMatrixCSC.

################################################# ACCESSORS #################################################################

nv(x::SparseMatrixCSC{Int}) = x.m

ne(x::SparseMatrixCSC{Int}) = nnz(x)

################################################# GENERATION ################################################################

function SparseMatrixCSC(nv::Int, eit::EdgeIter, erows::AbstractVector{Int})
   sparse(eit.us, eit.vs, erows, nv, nv, min)
end

function randindxs(nv::Int, ne::Int)
   sv = sprand(Int, nv, nv, ne/(nv*(nv-1)))
   sv = sv - spdiagm(diag(sv), 0)
   sv.nzval[:] = 1 : nnz(sv)
   return sv
end

function completeindxs(nv::Int)
   sv = sparse(spzeros(Int, nv, nv) .+ 1 - speye(Int, nv, nv))
   sv.nzval[:] = 1 : nnz(sv)
   return sv
end

################################################# PAIR GETINDEX #############################################################

###
# UNIT
###
Base.getindex(x::SparseMatrixCSC{Int}, e::EdgeID) = x[e.second, e.first]


###
# EDGE LIST
###
function Base.getindex(x::SparseMatrixCSC{Int}, es::EdgeList)
   n = length(es)
   vals = sizehint!(Vector{Int}(), n)
   for e in es
      push!(vals, getindex(x, e))
   end
   return vals
end


###
# EDGE ITER
###
function Base.getindex(x::SparseMatrixCSC{Int}, eit::EdgeIter)
   n = length(eit)
   vals = sizehint!(Vector{Int}(), n)
   for i in 1 : n
      @inbounds u = eit.us[i]
      @inbounds v = eit.vs[i]
      push!(vals, getindex(x, v, u))
   end
   return vals
end

################################################# PAIR SETINDEX #############################################################

###
# SINGLE
###
function Base.setindex!(x::SparseMatrixCSC{Int}, val::Int, e::EdgeID)
   x[e.second, e.first] = val
end


###
# SINGLE EDGE LIST
###
function Base.setindex!(x::SparseMatrixCSC{Int}, val, es::EdgeList)
   for e in es
      x[e] = val
   end
end


###
# MUTLI EDGE LIST
###
function Base.setindex!(x::SparseMatrixCSC{Int}, vals::AbstractVector{Int}, es::EdgeList)
   for i in eachindex(vals, es)
      @inbounds e = es[i]
      @inbounds val = vals[i]
      x[e] = val
   end
end


###
# EDGE ITER
###
function Base.setindex!(x::SparseMatrixCSC{Int}, val::Int, eit::EdgeIter)
   n = length(eit)
   for i in 1 : n
      @inbounds u = eit.us[i]
      @inbounds v = eit.vs[i]
      x[v,u] = val
   end
end

function Base.setindex!(x::SparseMatrixCSC{Int}, vals::AbstractVector{Int}, eit::EdgeIter)
   n = length(eit)
   for i in 1 : n
      @inbounds u = eit.us[i]
      @inbounds v = eit.vs[i]
      @inbounds val = vals[i]
      x[v,u] = val
   end
end
################################################# ADJACENCY #################################################################

###
# FADJ
###
function fadj(x::SparseMatrixCSC{Int}, v::VertexID)
   x.rowval[nzrange(x, v)]
end


###
# FADJ!
###
function fadj!(x::SparseMatrixCSC{Int}, v::VertexID, adj::Vector{Int})
   @inbounds p1 = x.colptr[v]
   @inbounds p2 = x.colptr[v+1]
   resize!(adj, p2 - p1)
   copy!(adj, 1, x.rowval, p1, p2 - p1)
end


###
# OUTDEGREE
###
function outdegree(x::SparseMatrixCSC{Int}, v::VertexID)
   @inbounds p1 = x.colptr[v]
   @inbounds p2 = x.colptr[v+1]
   return p2 - p1
end


###
# INDEGREE
###
function indegree(x::SparseMatrixCSC{Int}, v::VertexID)
   count(k->k == v, x.rowval)
end

################################################# ADDVERTEX ###############################################################

function addvertex!(x::SparseMatrixCSC{Int,Int})
   SparseMatrixCSC{Int,Int}(nv(x)+1, nv(x)+1, push!(x.colptr, x.colptr[end]), x.rowval, x.nzval)
end

################################################# ADDEDGE #################################################################

function addedge!(x::SparseMatrixCSC{Int}, e::EdgeID, erow::Int)
   x[e] = erow
end

function addedge!(x::SparseMatrixCSC{Int}, es::EdgeList, erows::Vector{Int})
   x[es] = erows
end

################################################# RMVERTEX ################################################################

function rmvertex!(x::SparseMatrixCSC{Int,Int}, vs)
   # Reorder entries in the index table
   x.nzval[:] = 1 : nnz(x)

   # Check which entries in the edge table have to be removed
   erows = vcat(x[EdgeIter(x, vs)], x[EdgeIter(x, :, vs)])

   # Delete entries from index table
   vlist = collect(1 : x.m)
   deleteat!(vlist, vs)
   x = x[vlist,vlist]
   x.nzval[:] = 1 : nnz(x)

   return(x, erows)
end

################################################# RMVERTEX ################################################################

function rmedge!(x::SparseMatrixCSC{Int}, e::EdgeID)
   erow = x[e]
   x[e] = 0
   dropzeros!(x)
   x.nzval[:] = 1 : nnz(x)
   return erow
end

function rmedge!(x::SparseMatrixCSC{Int}, es::EdgeList)
   erows = x[es]
   x[es] = 0
   dropzeros!(x)
   x.nzval[:] = 1 : nnz(x)
   return erows
end

################################################# SUBGRAPH ################################################################

###
# VS
###
function subgraph(x::SparseMatrixCSC{Int}, vs::VertexList)
   sv = x[vs,vs]
   erows = copy(nonzeros(sv))
   sv.nzval[:] = 1 : nnz(sv)
   return(sv, erows)
end


###
# ES
###
subgraph(x::SparseMatrixCSC{Int}, es::EdgeList) = subgraph(x, EdgeIter(es))

function subgraph(x::SparseMatrixCSC{Int}, eit::EdgeIter)
   nv = size(x, 1)
   erows = x[eit]
   sv = sparse(eit.us, eit.vs, collect(1 : length(eit)), nv, nv)
   return(sv, erows)
end


###
# VS & ES
###
subgraph(x::SparseMatrixCSC{Int}, vs::VertexList, es::EdgeList) = subgraph(x, vs, EdgeIter(es))

function subgraph(x::SparseMatrixCSC{Int}, vs::VertexList, eit::EdgeIter)
   nv = size(x, 1)
   sv = sparse(eit.us, eit.vs, x[eit], nv, nv)[vs,vs]
   erows = sort(nonzeros(sv))
   sv.nzval[:] = 1 : nnz(sv)
   return(sv, erows)
end
