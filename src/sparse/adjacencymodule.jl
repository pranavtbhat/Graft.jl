################################################# FILE DESCRIPTION #########################################################

# This file contains the SparseMatrixAM adjacency module, as well as an implementation of the AdjacencyModule interface.
 
################################################# IMPORT/EXPORT ############################################################
export
SparseMatrixAM, SparseMatrixIterator

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
   x = SparseMatrixAM(nv)
   while x.ne < ne
      u = rand(1:nv)
      v = rand(1:nv)
      u == v ||hasedge(x, u, v) || addedge!(x, u, v)
   end
   x
end

################################################# ACCESSORS ################################################################

@inline fdata(x::SparseMatrixAM) = x.fdata

@inline rdata(x::SparseMatrixAM) = x.rdata

################################################# INTERNAL IMPLEMENTATION ##################################################

# To avoid allocating memory
type SparseMatrixIterator
   rowval::Vector{Int}
   range::UnitRange{Int}
end

Base.length(x::SparseMatrixIterator) = length(x.range)
Base.start(x::SparseMatrixIterator) = start(x.range)
Base.done(x::SparseMatrixIterator, i) = i > last(x.range)
Base.next(x::SparseMatrixIterator, i) = x.rowval[i], i+1
Base.collect(x::SparseMatrixIterator) = x.rowval[x.range]

# Increase size of SparseMatrixCSC
function grow(x::SparseMatrixCSC{Bool,Int}, sz::Int)
   colptr = x.colptr
   SparseMatrixCSC{Bool,Int}(x.m+sz, x.n+sz, append!(colptr, fill(colptr[end], sz)), x.rowval, x.nzval)
end

################################################# IMPLEMENTATION ############################################################

nv(x::SparseMatrixAM) = x.nv

ne(x::SparseMatrixAM) = x.ne

Base.size(x::SparseMatrixAM) = (x.nv, x.ne)

function fadj(x::SparseMatrixAM, v::Int) # Messy
   M = fdata(x)
   SparseMatrixIterator(M.rowval, M.colptr[v] : (M.colptr[v+1]-1))
end

function badj(x::SparseMatrixAM, v::Int)
   M = rdata(x)
   SparseMatrixIterator(M.rowval, M.colptr[v] : (M.colptr[v+1]-1))
end

hasedge(x::SparseMatrixAM, u::VertexID, v::VertexID) = fdata(x)[u,v]

function addvertex!(x::SparseMatrixAM, numv::Int = 1)
   fdata(x) = grow(fdata(x), numv)
   rdata(x) = grow(rdata(x), numv)
   x.nv += numv
   nothing
end

function rmvertex!(x::SparseMatrixAM, v::Int)
   g.nv -= 1
   setindex!(fdata(x), false, v, :)
   setindex!(fdata(x), false, :, v)
   setindex!(rdata(x), false, :, v)
   setindex!(rdata(x), false, v, :)
   nothing
end

function addedge!(x::SparseMatrixAM, u::Int, v::Int)
   x.ne += 1
   setindex!(fdata(x), true, v, u)
   setindex!(rdata(x), true, u, v)
   nothing
end

function rmedge!(x::SparseMatrixAM, u::Int, v::Int)
   x.ne -= 1
   setindex!(fdata(x), false, v, u)
   setindex!(rdata(x), false, u, v)
   nothing
end

################################################# INTERFACE IMPLEMENTATION #####################################################

@inline nv(g::Graph{SparseMatrixAM}) = nv(adjmod(g))
@inline ne(g::Graph{SparseMatrixAM}) = ne(adjmod(g))
@inline Base.size(g::Graph{SparseMatrixAM}) = size(adjmod(g))
@inline fadj(g::Graph{SparseMatrixAM}, v::VertexID) = fadj(adjmod(g), v)
@inline badj(g::Graph{SparseMatrixAM}, v::VertexID) = radj(adjmod(g), v)
@inline addvertex!(g::Graph{SparseMatrixAM}) = addvertex!(adjmod(g))
@inline rmvertex!(g::Graph{SparseMatrixAM}, v::VertexID) = rmvertex!(adjmod(g), v)
@inline addedge!(g::Graph{SparseMatrixAM}, u::VertexID, v::VertexID) = addedge!(adjmod(g), u, v)
@inline rmedge!(g::Graph{SparseMatrixAM}, u::VertexID, v::VertexID) = rmedge!(adjmod(g), u, v)