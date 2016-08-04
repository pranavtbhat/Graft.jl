################################################# FILE DESCRIPTION #########################################################

# This file contains methods to merge graphs

################################################# IMPORT/EXPORT ############################################################

################################################# ADJACENCY ################################################################

function Base.merge(g1::Graph, g2::Graph)
   g = emptygraph(SparseGraph, 0)

   # Add vertices from g1
   ls1 = encode(g1, vertices(g1))
   g + ls1

   # Add vertex properties from g1
   vs1 = decode(g, ls1)
   for prop in listvprops(g1)
      setvprop!(g, vs1, getvprop(g1, :, prop), prop)
   end

   # Add vertices from g2
   ls2 = encode(g2, vertices(g2))
   g + ls2

   # Add vertex properties from g2
   vs2 = decode(g, ls2)
   for prop in listvprops(g2)
      setvprop!(g, vs2, getvprop(g2, :, prop), prop)
   end

   # Add edges from g1
   for l in ls1
      g[l] = g1[l]
   end

   # Add edges from g2
   for l in ls2
      g[l] = g2[l]
   end

   g
end
