################################################# FILE DESCRIPTION #########################################################

# This file contains methods to merge graphs

################################################# IMPORT/EXPORT ############################################################

################################################# ADJACENCY ################################################################
###
# TODO: Merge edge vertex properties, edge properties and labels
###
function Base.merge(g1::Graph, g2::Graph)
   if nv(g1) != nv(g2)
      error("Both graphs must have the same vertices")
   end
   Nv = nv(g1)

   es = vcat(edges(g1), edges(g2))
   sv = SparseMatrixCSC(Nv, es)
   reorder!(sv)

   Ne = nnz(sv)
   
   Graph(Nv, Ne, sv, DataFrame(), DataFrame(), IdentityLM(Nv))
end
