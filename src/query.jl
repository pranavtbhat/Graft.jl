################################################# FILE DESCRIPTION #########################################################

# This file contains methods, macros and operators aimed at providing the user a convenient UI to the graph datastructures 
# over the REPL.
 
################################################# IMPORT/EXPORT ############################################################

################################################# SPARSE GRAPHS ############################################################

# Getindex
Base.getindex(g::Graph, v::VertexID) = getvprop(g, v)
Base.getindex(g::Graph, u::VertexID, v::VertexID) = geteprop(g, u, v)
Base.getindex(g::Graph, v::VertexID, ::Colon) = adj(g, v)

# Setindex

Base.setindex!(g::Graph, val, v, propname) = setvprop!(g, v, propname, val)
Base.setindex!(g::Graph, val, u, v, propname) = seteprop!(g, u, v, propname, val)