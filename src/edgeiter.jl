################################################# FILE DESCRIPTION #########################################################

# This file an implementation of edge iteration.

################################################# IMPORT/EXPORT ############################################################

export EdgeIter

type EdgeIter <: EdgeList
   m::Int
   us::Vector{Int}
   vs::Vector{Int}
end

################################################# CONSTRUCTORS #############################################################

function EdgeIter(x::SparseMatrixCSC{Int})
   vs, us = findn(x)
   EdgeIter(nnz(x), us, vs)
end

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

Base.size(x::EdgeIter) = (x.m,)
Base.length(x::EdgeIter) = x.m

Base.copy(x::EdgeIter) = EdgeIter(nnz(x), copy(x.us), copy(x.vs))
Base.deepcopy(x::EdgeIter) = EdgeIter(nnz(x), deepcopy(x.us, deepcopy(x.vs)))

Base.issorted(x::EdgeIter) = true
Base.eltype(x::EdgeIter) = EdgeID

################################################# ITERATION ################################################################

Base.start(x::EdgeIter) = 1
Base.endof(x::EdgeIter) = length(x)
Base.eachindex(x::EdgeIter) = start(x) : endof(x)

Base.done(x::EdgeIter, i) = i > x.m

Base.next(x::EdgeIter, i) = (getindex(x, i), i+1)

function Base.collect(x::EdgeIter)
   es = sizehint!(Vector{EdgeID}(), x.m)
   for i in eachindex(x.us, x.vs)
      push!(es[i], EdgeID(x.us[i], x.vs[i]))
   end
   es
end

################################################# GETINDEX ##################################################################

Base.getindex(x::EdgeIter, i::Int) = EdgeID(x.us[i], x.vs[i])

function Base.getindex(x::EdgeIter, indxs::AbstractVector{Int})
   EdgeIter(length(indxs), x.us[indxs], x.vs[indxs])
end

Base.getindex(x::EdgeIter, ::Colon) = copy(x)

################################################# SHOW ######################################################################

Base.showarray(io::IO, x::EdgeIter) = show(io, x)

function Base.show(io::IO, x::EdgeIter)
   write(io, "Edge Iterator with $(x.m) values")
end
