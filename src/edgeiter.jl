################################################# FILE DESCRIPTION #########################################################

# This file an implementation of edge iteration.

################################################# IMPORT/EXPORT ############################################################

export EdgeIter

"""
An abstraction for alloc-free, fast edge iteration
"""
type EdgeIter <: EdgeList
   m::Int
   us::Vector{Int}
   vs::Vector{Int}
end

################################################# CONSTRUCTORS #############################################################

""" An iterator containing all edges in an adjacency matrix """
function EdgeIter(x::SparseMatrixCSC{Int})
   vs, us = findn(x)
   EdgeIter(nnz(x), us, vs)
end

""" An iterator containing all edges starting from a vertex """
function EdgeIter(x::SparseMatrixCSC{Int}, v::Int)
   adj = fadj(x, v)
   m = length(adj)
   EdgeIter(m, fill(v, m), adj)
end

""" An iterator containing all edges ending at a vertex """
function EdgeIter(x::SparseMatrixCSC{Int}, ::Colon, v::VertexID)
   EdgeIter(x.', v).'
end

""" An iterator containing all edges starting at a list of vertices """
function EdgeIter(x::SparseMatrixCSC{Int}, vlist::VertexList)
   Nerows = sum([outdegree(x, v) for v in vlist])
   us = Vector{Int}(Nerows)
   vs = Vector{Int}(Nerows)

   Cerows = 1
   for v in vlist
      p1 = x.colptr[v]
      p2 = x.colptr[v+1]
      sz = p2 - p1
      us[Cerows : (Cerows + sz - 1)] = v
      copy!(vs, Cerows, x.rowval, p1, sz)
      Cerows += sz
   end

   EdgeIter(Nerows, us, vs)
end

""" An iterator containing all edges ending at a list of vertices """
function EdgeIter(x::SparseMatrixCSC{Int}, ::Colon, vlist::VertexList)
   EdgeIter(x.', vlist).'
end

""" Split an input edge list into an iterator """
function EdgeIter(es::EdgeList)
   m = length(es)
   us = sizehint!(Vector{Int}(), m)
   vs = sizehint!(Vector{Int}(), m)

   for e in es
      push!(us, e.first)
      push!(vs, e.second)
   end

   EdgeIter(m, us, vs)
end

################################################# BASICS ###################################################################

(==)(x::EdgeIter, y::EdgeIter) = x.m == y.m && x.us == y.us && x.vs == y.vs

Base.length(x::EdgeIter) = x.m
Base.size(x::EdgeIter) = (x.m,)

Base.copy(x::EdgeIter) = EdgeIter(x.m, copy(x.us), copy(x.vs))
Base.deepcopy(x::EdgeIter) = EdgeIter(x.m, deepcopy(x.us), deepcopy(x.vs))

Base.issorted(x::EdgeIter) = true
Base.eltype(x::EdgeIter) = EdgeID

Base.transpose(x::EdgeIter) = EdgeIter(x.m, copy(x.vs), copy(x.us))

################################################# ITERATION ################################################################

Base.start(x::EdgeIter) = 1
Base.endof(x::EdgeIter) = length(x)
Base.eachindex(x::EdgeIter) = start(x) : endof(x)

Base.done(x::EdgeIter, i) = i > x.m

Base.next(x::EdgeIter, i) = (getindex(x, i), i+1)

function Base.collect(x::EdgeIter)
   n  = length(x)
   es = sizehint!(Vector{EdgeID}(), n)

   for i in 1 : n
      @inbounds u = x.us[i]
      @inbounds v = x.vs[i]
      push!(es, EdgeID(u, v))
   end

   return es
end

################################################# GETINDEX ##################################################################

""" Get the ith edge in the iterator """
Base.getindex(x::EdgeIter, i::Int) = EdgeID(x.us[i], x.vs[i])

""" Get a new iterator containing a subset of the edges """
function Base.getindex(x::EdgeIter, indxs::AbstractVector{Int})
   EdgeIter(length(indxs), x.us[indxs], x.vs[indxs])
end

""" Get a copy of the iterator """
Base.getindex(x::EdgeIter, ::Colon) = copy(x)

################################################# SHOW ######################################################################

Base.showarray(io::IO, x::EdgeIter) = show(io, x)

function Base.show(io::IO, x::EdgeIter)
   write(io, "Edge Iterator with $(x.m) values")
end

################################################# CONCATENATION #############################################################

""" Concatenate two iterators """
function Base.vcat(eit1::EdgeIter, eit2::EdgeIter)
   EdgeIter(eit1.m + eit2.m, vcat(eit1.us, eit2.us), vcat(eit1.vs, eit2.vs))
end
