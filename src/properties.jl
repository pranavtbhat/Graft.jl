################################################# FILE DESCRIPTION #########################################################

# Parallel allows the assignment of properties (key-value pairs) the the edges and vertices in a graph. The key can 
# be any arbitrary julia object, and therefore keys must be mapped on to integers, before they can be used to for indexing.
# The PropertyModule therefore stores values of type V, indexed by objects of type K.

################################################# IMPORT/EXPORT ############################################################
export
# Types
PropertyModule, NullModule,
# Constants
Property_Interface_Methods,
# Properties Interface
listvprops, listeprops, getvprop, geteprop, setvprop!, seteprop!

abstract PropertyModule{K,V}

################################################# INTERFACE ################################################################

const Property_Interface_Methods = [:listvprops, :listeprops, :getvprop, :geteprop, :setvprop!, :seteprop!]

""" List the vertex properties contained in the graph """
@interface listvprops{AM,K,V}(g::Graph{AM,PropertyModule{K,V}})

""" List the edge properties contained in the graph """
@interface listeprops{AM,K,V}(g::Graph{AM,PropertyModule{K,V}})

""" Return the properties of a particular vertex in the graph """
@interface getvprop{AM,K,V}(g::Graph{AM,PropertyModule{K,V}}, v::VertexID)
@interface getvprop{AM,K,V}(g::Graph{AM,PropertyModule{K,V}}, v::VertexID, propname)

""" Return the properties of a particular edge in the graph """
@interface geteprop{AM,K,V}(g::Graph{AM,PropertyModule{K,V}}, u::VertexID, v::VertexID)
@interface geteprop{AM,K,V}(g::Graph{AM,PropertyModule{K,V}}, u::VertexID, v::VertexID, propname)

""" Set the value for a vertex property """
@interface setvprop!{AM,K,V}(g::Graph{AM,PropertyModule{K,V}}, v::VertexID, props::Dict)
@interface setvprop!{AM,K,V}(g::Graph{AM,PropertyModule{K,V}}, v::VertexID, propname, val)

""" Set the value for an edge property """
@interface seteprop!{AM,K,V}(g::Graph{AM,PropertyModule{K,V}}, u::VertexID, v::VertexID, props::Dict)
@interface seteprop!{AM,K,V}(g::Graph{AM,PropertyModule{K,V}}, u::VertexID, v::VertexID, propname, val)

################################################# IMPLEMENTATIONS ##########################################################

# Null Implementation

""" Null property module. Does not implement the PropertyInterface """
immutable NullModule
end

listvprops{AM}(g::Graph{AM,NullModule}) = Void()
listeprops{AM}(g::Graph{AM,NullModule}) = Void()
getvprop{AM}(g::Graph{AM,NullModule}, v::VertexID) = Void()
getvprop{AM}(g::Graph{AM,NullModule}, v::VertexID, propname) = Void()
geteprop{AM}(g::Graph{AM,NullModule}, u::VertexID, v::VertexID) = Void()
geteprop{AM}(g::Graph{AM,NullModule}, u::VertexID, v::VertexID, propname) = Void()
setvprop!{AM}(g::Graph{AM,NullModule}, v::VertexID, props::Dict) = Void()
setvprop!{AM}(g::Graph{AM,NullModule}, v::VertexID, propname, val) = Void()
seteprop!{AM}(g::Graph{AM,NullModule}, u::VertexID, v::VertexID, props::Dict) = Void()
seteprop!{AM}(g::Graph{AM,NullModule}, u::VertexID, v::VertexID, propname, val) = Void()

# NDSparse Implementation
include("ndsparse/propertymodule.jl")

# Dict Implementation
include("dict/propertymodule.jl")