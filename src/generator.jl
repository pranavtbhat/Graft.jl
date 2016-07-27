################################################# FILE DESCRIPTION #########################################################

# This file contains methods to generate graphs

################################################# IMPORT/EXPORT ############################################################
export
# Types
emptygraph, randgraph, completegraph

################################################# EMTPY GRAPH ##############################################################

function emptygraph{G<:Graph}(::Type{G}, nv::Int)
   AM,PM = G.parameters
   Graph(AM(nv), PM(nv), LabelModule(nv))
end

emptygraph(nv::Int) = emptygraph(SparseGraph, nv)

################################################# RANDGRAPH ################################################################

function randgraph{G<:Graph}(::Type{G}, nv::Int, ne::Int)
   AM,PM = G.parameters
   Graph(AM(nv, ne), PM(nv), LabelModule(nv))
end

randgraph(nv::Int, ne::Int) = randgraph(SparseGraph, nv, ne)

randgraph(nv::Int) = randgraph(SparseGraph, nv, rand(1 : (nv * (nv-1))))

################################################# COMPLETE GRAPH ###########################################################

function completegraph{G<:Graph}(::Type{G}, nv::Int)
   AM,PM = G.parameters
   ne = nv * (nv - 1)
   Graph(AM(nv, ne), PM(nv), LabelModule(nv))
end

completegraph(nv::Int) = completegraph(SparseGraph, nv)
