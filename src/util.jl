################################################# FILE DESCRIPTION #########################################################

# This file contains package wide type aliases, constants, macros, utility methods, etc.

################################################# IMPORT/EXPORT ############################################################

export
# Type Aliases
VertexID, EdgeID, VertexList, EdgeList

################################################# TYPE ALIASES #############################################################

""" Datatype used to store vertex id numbers """
typealias VertexID Int

""" Datatype used to store edges """
typealias EdgeID Pair{VertexID,VertexID}

""" A list of Vertex IDs """
typealias VertexList AbstractVector{VertexID}

""" A list of Edge IDs """
typealias EdgeList AbstractVector{EdgeID}
