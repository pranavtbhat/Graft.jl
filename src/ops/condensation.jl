################################################# FILE DESCRIPTION #########################################################

# This file contains methods to obtain condensations of graphs

################################################# IMPORT/EXPORT ############################################################
export
# Methods
condensation

################################################# ADJACENCY ################################################################

Base.zero(::Type{Graph}) = nothing

function condensation(g::Graph, d::Dict)
   Nv = length(d)
   h = emptygraph(Graph{SparseMatrixAM,LinearPM}, 0)

   for (l,vlist) in d
      vs = decode(g, vlist)

      v = addvertex!(h, l)
      setvprop!(h, v, subgraph(g, vs), "graph")

      setvprop!(h, v, vlist, "vertices")

      propvec = [getvprop(g, x) for x in vs]

      setvprop!(h, v, propvec, "properties")
   end

   h
end
