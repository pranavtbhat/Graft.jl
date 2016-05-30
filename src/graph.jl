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
emptygraph, nv, ne, adj, getprop, setprop!, addvertex, addedge

################################################# GRAPH INTERFACE ##########################################################

""" Graph Interface that all subtypes are required to adhere to """
abstract Graph

###
# CONSTRUCTOR INTERFACE
###
""" Return an empty graph of a given type """
@interface emptygraph(::Type{Graph})



###
# BASIC GRAPH INTERFACE
###
""" Return the number of vertices in the graph """
@interface nv(g::Graph)

""" Return the number of edges in the graph """
@interface ne(g::Graph)

""" Return V x E """
@interface size(g::Graph)

""" Return the adjacencies of a given vertex """
@interface adj(g::Graph, v::VertexID)

""" Add a new vertex to the graph. Returns a new graph """
@interface addvertex(g::Graph, props::Pair...)

""" Add a new edge to the graph. Returns a new graph """
@interface addedge(g::Graph, u::VertexID, v::VertexID, props::Pair...)




###
# PROPERTIES INTERFACE
###
""" List the vertex properties contained in a graph """
@interface listvprops(g::Graph)

""" List the edge properties contained in the graph """
@interface listeprops(g::Graph)

""" Return the properties of a particular vertex in the graph, as a dictionary """
@interface getprop(g::Graph, v::VertexID)

""" Return the value of a property for a particular vertex in the graph """
@interface getprop(g::Graph, v::VertexID, propname::PropName)

""" Return the properties of a particular edge in the graph, as a dictionary """
@interface getprop(g::Graph, u::VertexID, v::VertexID)

"""Return the value of a property for a particular edge in the graph """
@interface getprop(g::Graph, u::VertexID, v::VertexID, propname::PropName)

""" Set the value for a vertex's property """
@interface setprop!(g::Graph, v::VertexID, propname::PropName, val::Any)

""" Set the value for an edge's property """
@interface setprop!(g::Graph, u::VertexID, v::VertexID, propname::PropName, val::Any)



################################################# SPARSE GRAPH INTERFACE ###################################################

""" Sparse Graph Interface that all graphs relying on NDSparse are required to adhere to """
abstract SparseGraph <: Graph

include("localsparsegraph.jl")



