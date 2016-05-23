################################################# FILE DESCRIPTION #########################################################

# This file contains the core graph definitions. ParallelGraphs provides a Graph interface that all 
# graph types must adhere to. 
# Some features common to all graph types:
# 1. Vertices and edges can be assigned properties
# 2. All graph types are IMMUTABLE. Mutating the graph will create a new graph! Data will be reused to the extent possible.
 
################################################# IMPORT/EXPORT ############################################################
import NDSparseData: flush!
export 
# Types
Graph, SparseGraph,
# Graph Interface methods
nv, ne, adj,
# SparseGraph Interface methods
getprop

################################################# GRAPH INTERFACE ##########################################################

""" Graph Interface that all subtypes are required to adhere to """
abstract Graph

""" Return the number of vertices in the graph """
@interface nv(g::Graph)

""" Return the number of edges in the graph """
@interface ne(g::Graph)

""" Return the adjacencies of a given vertex """
@interface adj(g::Graph, v::VertexID)

""" Return the properties of a particular vertex in the graph, as a dictionary """
@interface getprop(g::Graph, v::VertexID)

""" Return the value of a property for a particular vertex in the graph """
@interface getprop(g::Graph, v::VertexID, propname::AbstractString)

""" Return the properties of a particular edge in the graph, as a dictionary """
@interface getprop(g::Graph, u::VertexID, v::VertexID)

"""Return the value of a property for a particular edge in the graph """
@interface getprop(g::Graph, u::VertexID, v::VertexID, propname::AbstractString)

################################################# SPARSE GRAPH INTERFACE ###################################################

""" Sparse Graph Interface that all graphs relying on NDSparse are required to adhere to """
abstract SparseGraph <: Graph

""" Prepare the graph for querying """
@interface flush!(g::SparseGraph)


include("sparsegraph.jl")



