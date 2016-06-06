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

@inline nv(g::Graph{SparseMatrixAM}) = adjmod(g).nv

@inline ne(g::Graph{SparseMatrixAM}) = adjmod(g).ne

@inline Base.size(g::Graph{SparseMatrixAM}) = (nv(g), ne(g))

function fadj(g::Graph{SparseMatrixAM}, v::VertexID) # Messy
   M = data(adjmod(g))
   M.rowval[M.colptr[v] : (M.colptr[v+1]-1)]
end

function badj(g::Graph{SparseMatrixAM}, v::VertexID) # Messy
   M = data(adjmod(g))
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

function addvertex!(g::Graph{SparseMatrixAM})
   adjmod(g).nv += 1
   nothing
end

function rmvertex!(g::Graph{SparseMatrixAM}, v::VertexID)
   adjmod(g).nv -= 1
   setindex!(data(adjmod(g)), false, v, :)
   setindex!(data(adjmod(g)), false, :, v)
   nothing
end

function addedge!(g::Graph{SparseMatrixAM}, u::VertexID, v::VertexID)
   adjmod(g).ne += 1
   setindex!(data(adjmod(g)), true, v, u)
   nothing
end

function rmedge!(g::Graph{SparseMatrixAM}, u::VertexID, v::VertexID)
   adjmod(g).ne -= 1
   setindex!(data(adjmod(g)), false, v, u)
   nothing
end

