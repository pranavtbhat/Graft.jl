################################################# FILE DESCRIPTION #########################################################

# This file contains methods to convert between module types

################################################# IMPORT/EXPORT ############################################################

################################################# ADJACENCY ################################################################

if CAN_USE_LG
   function LightGraphsAM(x::SparseMatrixAM)
      y = LightGraphsAM(nv(x))
      for e in edges(x)
         addedge!(y, e...)
      end
      y
   end

   function SparseMatrixAM(x::LightGraphsAM)
      Nv = nv(x)
      Ne = ne(x)
      fdata = init_spmx(Nv, collect(edges(x)), trues(Ne))
      bdata = fdata'
      adjvec = zeros(VertexID, Nv)
      SparseMatrixAM(Nv, Ne, fdata, bdata, adjvec)
   end
end
