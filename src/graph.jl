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
# Constructor Interface
emptygraph,
# Basic Graph Interface
nv, ne, fadj, badj, addvertex!, addedge!,
# Properties Interface
listvprops, listeprops, getvprop, geteprop, setvprop!, seteprop!

################################################# GRAPH INTERFACE ##########################################################

""" Graph Interface that all subtypes are required to adhere to """
abstract Graph

###
# CONSTRUCTOR INTERFACE
###
""" Return an empty graph of a given type """
@interface emptygraph(::Type{Graph}, num_verices::Int = 0)



###
# BASIC GRAPH INTERFACE
###
""" Return the number of vertices in the graph """
@interface nv(g::Graph)

""" Return the number of edges in the graph """
@interface ne(g::Graph)

""" Return V x E """
@interface Base.size(g::Graph)

""" Return the forward adjacencies of a given vertex """
@interface fadj(g::Graph, v::VertexID)

""" Return the reverse adjacencies of a given vertex """
@interface badj(g::Graph, v::VertexID)

""" Add a new vertex to the graph """
@interface addvertex!(g::Graph)
@interface addvertex!{K<:PropName,V<:Any}(g::Graph, props::Dict{K,V})

""" Add a new edge to the graph """
@interface addedge!(g::Graph, u::VertexID ,v::VertexID)
@interface addedge!{K<:PropName,V<:Any}(g::Graph, u::VertexID, v::VertexID, props::Dict{K,V})




###
# PROPERTIES INTERFACE
###
""" List the vertex properties contained in a graph """
@interface listvprops(g::Graph)

""" List the edge properties contained in the graph """
@interface listeprops(g::Graph)

""" Return the properties of a particular vertex in the graph """
@interface getvprop(g::Graph, v::VertexID)
@interface getvprop(g::Graph, v::VertexID, propid::PropID)
@interface getvprop(g::Graph, v::VertexID, propname::PropName)

""" Return the properties of a particular edge in the graph """
@interface geteprop(g::Graph, u::VertexID, v::VertexID)
@interface geteprop(g::Graph, u::VertexID, v::VertexID, propid::PropID)
@interface geteprop(g::Graph, u::VertexID, v::VertexID, propname::PropName)

""" Set the value for a vertex/edge property """
@interface setvprop!{K<:PropName,V<:Any}(g::Graph, v::VertexID, props::Dict{K,V})
@interface setvprop!(g::Graph, v::VertexID, propid::PropID, val::Any)
@interface setvprop!(g::Graph, v::VertexID, propname::PropName, val::Any)

@interface seteprop!{K<:PropName,V<:Any}(g::Graph, u::VertexID, v::VertexID, props::Dict{K,V})
@interface seteprop!(g::Graph, u::VertexID, v::VertexID, propid::PropID, val::Any)
@interface seteprop!(g::Graph, u::VertexID, v::VertexID, propname::PropName, val::Any)



################################################# GRAPH SUBTYPES #############################################################

include("sparsegraph.jl")



