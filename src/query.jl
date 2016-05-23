################################################# FILE DESCRIPTION #########################################################

# This file contains methods, macros and operators aimed at providing the user a convenient UI to the graph datastructures 
# over the REPL.
 
################################################# IMPORT/EXPORT ############################################################

################################################# SPARSE GRAPHS ############################################################

# Getindex
Base.getindex(g::Graph, v::VertexID) = getprop(g, v)
Base.getindex(g::Graph, u::VertexID, v::VertexID) = getprop(g, u, v)
Base.getindex(g::Graph, v::VertexID, ::Colon) = adj(g, v)
