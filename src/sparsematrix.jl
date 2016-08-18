################################################# FILE DESCRIPTION ##########################################################

# This file contains graph compatibility methods for SparseMatrixCSC.

################################################# HELPERS ###################################################################

""" Sort the index entries """
function reorder!(x::SparseMatrixCSC)
   x.nzval[:] = 1 : nnz(x)
   return x
end


################################################# ACCESSORS #################################################################

""" The number of vertices in the adjacency matrix """
nv(x::SparseMatrixCSC{Int}) = x.m

""" The number of edges in the adjacency matrix """
ne(x::SparseMatrixCSC{Int}) = nnz(x)

################################################# GENERATION ################################################################

""" Build an adjacency matrix from an edge iterator """
function SparseMatrixCSC(nv::Int, eit::EdgeIter)
   sparse(eit.us, eit.vs, 1, nv, nv, min)
end

"""
Spawn a random sparse matrix, sort indices and remove self loops

The number of edges in the sparse matrix may not equal the input ne,
and is more likely to be an approximate
"""
function randindxs(nv::Int, ne::Int)
   sv = sprand(Int, nv, nv, ne/(nv*(nv-1)))
   sv = sv - spdiagm(diag(sv), 0)
   reorder!(sv)
   return sv
end

"""
Spawn a random sparse matrix denoting a complete graph without
self loops. The returned matrix resembles a non-sparse matrix,
so it'd be unwise to use this for a large number of vertices
"""
function completeindxs(nv::Int)
   sv = sparse(spzeros(Int, nv, nv) .+ 1 - speye(Int, nv, nv))
   reorder!(sv)
   return sv
end

################################################# PAIR GETINDEX #############################################################

""" Retrieve an edges' index in the ddge dataframe """
Base.getindex(x::SparseMatrixCSC{Int}, e::EdgeID) = x[e.second, e.first]


""" Retrieve the edge dataframe indices for a list of edges """
function Base.getindex(x::SparseMatrixCSC{Int}, es::EdgeList)
   n = length(es)
   vals = sizehint!(Vector{Int}(), n)
   for e in es
      push!(vals, getindex(x, e))
   end
   return vals
end


""" Retrieve the edge dataframe indices for all edges in an edge iterator """
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

""" Change an edge's index in the edge dataframe """
function Base.setindex!(x::SparseMatrixCSC{Int}, val::Int, e::EdgeID)
   x[e.second, e.first] = val
end


""" Change the edge dataframe indices for a list of edges """
function Base.setindex!(x::SparseMatrixCSC{Int}, val, es::EdgeList)
   for e in es
      x[e] = val
   end
end


""" Change the edge dataframe indices for a list of edges """
function Base.setindex!(x::SparseMatrixCSC{Int}, vals::AbstractVector{Int}, es::EdgeList)
   for i in eachindex(vals, es)
      @inbounds e = es[i]
      @inbounds val = vals[i]
      x[e] = val
   end
end


""" Change the edge dataframe indices for all edges in an iterator """
function Base.setindex!(x::SparseMatrixCSC{Int}, val::Int, eit::EdgeIter)
   n = length(eit)
   for i in 1 : n
      @inbounds u = eit.us[i]
      @inbounds v = eit.vs[i]
      x[v,u] = val
   end
end

""" Change the edge dataframe indices for all edges in an iterator """
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

"""
Retrieve a list of vertices connected to vertex v.

This method spwans a new array, so is slow and malloc prone.
"""
function fadj(x::SparseMatrixCSC{Int}, v::VertexID)
   x.rowval[nzrange(x, v)]
end


"""
Retrieve a list of vertices connect to vertex v.

This method copies the adjacencies onto the input array,
and is comparitively faster, and causes no mallocs.
"""
# TODO: Replace this functionaly with fast subarrays, once that gets out.
function fadj!(x::SparseMatrixCSC{Int,Int}, v::VertexID, adj::Vector{Int})
   @inbounds p1 = x.colptr[v]
   @inbounds p2 = x.colptr[v+1]
   resize!(adj, p2 - p1)
   copy!(adj, 1, x.rowval, p1, p2 - p1)
end


""" Compute the outdegree of a vertex """
function outdegree(x::SparseMatrixCSC{Int}, v::VertexID)
   @inbounds p1 = x.colptr[v]
   @inbounds p2 = x.colptr[v+1]
   return p2 - p1
end

""" Compute outdegrees for a list of vertices """
function outdegree(x::SparseMatrixCSC{Int}, vs::VertexList)
   [outdegree(x, v) for v in vs]
end

""" Compute outdegrees for all vertices in the graph """
function outdegree(x::SparseMatrixCSC{Int})
   degs = Vector{Int}(nv(x))
   for v in 1 : nv(x)
      degs[v] = x.colptr[v+1] - x.colptr[v]
   end
   return degs
end


"""
Compute the indegree of a vertex. This method is slow
since reverse adjacencies are not stored
"""
function indegree(x::SparseMatrixCSC{Int}, v::VertexID)
   count = 0
   for i in x.rowval
      if i == v
         count += 1
      end
   end
   return count
end

""" Compute the indegrees for a list of vertices. Note that the list may not be unique! """
function indegree(x::SparseMatrixCSC{Int}, vs::VertexList)
   degs = zeros(Int, nv(x))
   for i in x.rowval
      degs[i] += 1
   end
   return degs[vs]
end

""" Compute the indegrees for all vertices in the graph """
function indegree(x::SparseMatrixCSC{Int})
   degs = zeros(Int, nv(x))
   for i in x.rowval
      degs[i] += 1
   end
   return degs
end

################################################# ADDVERTEX ###############################################################

"""
Grow the input sparsematrix to hold another vertex.
Returns a new matrix, since the SparseMatrixCSC type is immutable.
The input matrix is reused in the construction.
"""
function addvertex!(x::SparseMatrixCSC{Int,Int})
   SparseMatrixCSC{Int,Int}(nv(x)+1, nv(x)+1, push!(x.colptr, x.colptr[end]), x.rowval, x.nzval)
end

################################################# ADDEDGE #################################################################

""" Insert an edge into the sparsematrix """
function addedge!(x::SparseMatrixCSC{Int}, e::EdgeID, erow::Int)
   x[e] = erow
end

"""  Insert a list of edges into the sparsematrix """
function addedge!(x::SparseMatrixCSC{Int}, es::EdgeList, erows::Vector{Int})
   x[es] = erows
end

################################################# RMVERTEX ################################################################

"""
Remove a vertex(s) from the sparsematrx. This method
first computes a list of rows to be removed from the edge dataframe.
It then computes and returns a subset of the input sparsematrix, and reorders
edge indices.
"""
function rmvertex!(x::SparseMatrixCSC{Int,Int}, vs)
   # Reorder entries in the index table
   reorder!(x)

   # Check which entries in the edge table have to be removed
   erows = vcat(x[EdgeIter(x, vs)], x[EdgeIter(x, :, vs)])

   # Delete entries from index table
   vlist = collect(1 : x.m)
   deleteat!(vlist, vs)
   x = x[vlist,vlist]
   reorder!(x)

   return(x, erows)
end

################################################# RMVERTEX ################################################################

"""
Remove an edge from the sparsematrix. This method returns the edge dataframe
index of the removed edge.
"""
function rmedge!(x::SparseMatrixCSC{Int}, e::EdgeID)
   erow = x[e]
   x[e] = 0
   dropzeros!(x)
   x.nzval[:] = 1 : nnz(x)
   return erow
end

"""
Remove edges from the sparsematrix. This method returns the edge dataframe
index of the removed edges.
"""
function rmedge!(x::SparseMatrixCSC{Int}, es::EdgeList)
   erows = x[es]
   x[es] = 0
   dropzeros!(x)
   x.nzval[:] = 1 : nnz(x)
   return erows
end

################################################# SUBGRAPH ################################################################

"""
Compute a subgraph containing the list of input vertices. This method
uses vector getindex and is very fast. It computes the list of rows in
the edge dataframed to be copied into the subgraph, and reorders entries in the
new adjacency matrix
"""
function subgraph(x::SparseMatrixCSC{Int}, vs::VertexList)
   sv = x[vs,vs]
   erows = copy(nonzeros(sv))
   reorder!(sv)
   return(sv, erows)
end


"""
Compute a subgraph from a list of edges. This method builds a new
adjacency matrix from the iterator, reorders the indices and returns a
list of edge dataframe rows to be copied into the subgraph.
"""
function subgraph(x::SparseMatrixCSC{Int}, eit::EdgeIter)
   nv = size(x, 1)
   erows = x[eit]
   sv = sparse(eit.vs, eit.us, collect(1 : length(eit)), nv, nv)
   return(sv, erows)
end

subgraph(x::SparseMatrixCSC{Int}, es::EdgeList) = subgraph(x, EdgeIter(es))


"""
Compute a subgraph from a list of vertices and a list of edges. This method
first computes a subgraph comprising of the input edges, and then proceeds
to preserve only the input list of vertices. Reorders indices and returns a
list of edge table rows to be copied into the subgraph.
"""
function subgraph(x::SparseMatrixCSC{Int}, vs::VertexList, eit::EdgeIter)
   nv = size(x, 1)
   sv = sparse(eit.vs, eit.us, x[eit], nv, nv)[vs,vs]
   erows = sort(nonzeros(sv))
   reorder!(sv)
   return(sv, erows)
end

subgraph(x::SparseMatrixCSC{Int}, vs::VertexList, es::EdgeList) = subgraph(x, vs, EdgeIter(es))
