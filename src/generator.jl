################################################# FILE DESCRIPTION #########################################################

# This file contains methods to generate graphs

################################################# IMPORT/EXPORT ############################################################
export
# Types
emptygraph, randgraph, completegraph

################################################# EMTPY GRAPH ##############################################################

emptygraph(nv::Int) = Graph(nv)

################################################# RANDGRAPH ################################################################

randgraph(nv::Int, ne::Int) = Graph(nv, ne)
randgraph(nv::Int) = Graph(nv, rand(1 : (nv * (nv-1))))

###
# TODO: MORE RANDOM GENERATORS
###

################################################# COMPLETE GRAPH ###########################################################

function completegraph(nv::Int)
   Graph(completeindxs(nv))
end
