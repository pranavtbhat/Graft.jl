################################################# FILE DESCRIPTION #########################################################

# This file contains methods to generate graphs

################################################# IMPORT/EXPORT ############################################################
export
# Types
emptygraph, randgraph, complete_graph

################################################# EMTPY GRAPH ##############################################################

function emptygraph{G<:Graph}(::Type{G}, nv::Int)
   AM,PM = G.parameters
   Graph(AM(nv), PM(nv), LabelModule(nv))
end

################################################# RANDGRAPH ################################################################

function randgraph{G<:Graph}(::Type{G}, nv::Int, ne::Int)
   AM,PM = G.parameters
   Graph(AM(nv, ne), PM(nv), LabelModule(nv))
end

################################################# COMPLETE GRAPH ###########################################################

function complete_graph{G<:Graph}(::Type{G}, nv::Int)
   AM,PM = G.parameters
   ne = nv * (nv - 1)
   Graph(AM(nv, ne), PM(nv), LabelModule(nv))
end
