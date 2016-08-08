################################################# FILE DESCRIPTION #########################################################

# This file contains macros aimed at providing the user a convenient UI to the graph datastructures
# over the REPL.

################################################# IMPORT/EXPORT ############################################################

export exec

################################################# LITERALS #################################################################

exec(x::LiteralNode) = x.val

################################################# GRAPHS ###################################################################

exec(x::SimpleGraphNode) = x.g

################################################# VECTOR NODES #############################################################

exec(x::VertexPropertyNode) = getvprop(exec(x.graph), :, x.vprop)

exec(x::EdgePropertyNode) = geteprop(exec(x.graph), :, x.eprop)
