################################################# FILE DESCRIPTION #########################################################

# This file contains the SparseMatrixAM adjacency module, as well as an implementation of the AdjacencyModule interface.
 
################################################# IMPORT/EXPORT ############################################################
export
SparseMatrixAM

type SparseMatrixAM <: AdjacencyModule
   nv::Int
   ne::Int
   data::SparseMatrixCSC{Bool, Int}

   function SparseMatrixAM(nv=0)
      self = new()
      self.nv = nv
      self.ne = 0
      self.data = sprandbool(MAX_GRAPH_SIZE..., 0.0)
      self
   end
end

################################################# ACCESSORS ################################################################

@inline data(x::SparseMatrixAM) = x.data

################################################# INTERFACE IMPLEMENTATION #################################################

@inline nv(x::SparseMatrixAM) = x.nv

@inline ne(x::SparseMatrixAM) = x.ne

@inline Base.size(x::SparseMatrixAM) = (nv(x), ne(x))

function fadj(x::SparseMatrixAM, v::VertexID) # Messy
   M = data(x)
   M.rowval[M.colptr[v] : (M.colptr[v+1]-1)]
end

function badj(x::SparseMatrixAM, v::VertexID) # Messy
   M = data(x)
   result = Array(Int, 0)
   @inbounds for col in 1:size(M, 2)
      row = v
      ptr = M.colptr[col]
      stop = M.colptr[col+1]-1
      if ptr <= stop
         if M.rowval[ptr] <= row
            ptr = searchsortedfirst(M.rowval, row, ptr, stop, Base.Order.Forward)
            if ptr <= stop && M.rowval[ptr] == row
               push!(result, col)
            end
         end
      end
   end
   result
end

function addvertex!(x::SparseMatrixAM)
   x.nv += 1
   nothing
end

function rmvertex!(x::SparseMatrixAM, v::VertexID)
   x.nv -= 1
   setindex!(data(x), false, v, :)
   setindex!(data(x), false, :, v)
   nothing
end

function addedge!(x::SparseMatrixAM, u::VertexID, v::VertexID)
   x.ne += 1
   setindex!(data(x), true, v, u)
   nothing
end

function rmedge!(x::SparseMatrixAM, u::VertexID, v::VertexID)
   x.ne -= 1
   setindex!(data(x), false, v, u)
   nothing
end

