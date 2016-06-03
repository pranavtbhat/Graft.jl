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
@interface listvprops{K,V}(x::PropertyModule{K,V})

""" List the edge properties contained in the graph """
@interface listeprops{K,V}(x::PropertyModule{K,V})

""" Return the properties of a particular vertex in the graph """
@interface getvprop{K,V}(x::PropertyModule{K,V}, v::VertexID)
@interface getvprop{K,V}(x::PropertyModule{K,V}, v::VertexID, propname)

""" Return the properties of a particular edge in the graph """
@interface geteprop{K,V}(x::PropertyModule{K,V}, u::VertexID, v::VertexID)
@interface geteprop{K,V}(x::PropertyModule{K,V}, u::VertexID, v::VertexID, propname)

""" Set the value for a vertex property """
@interface setvprop!{K,V}(x::PropertyModule{K,V}, v::VertexID, props::Dict)
@interface setvprop!{K,V}(x::PropertyModule{K,V}, v::VertexID, propname, val)

""" Set the value for an edge property """
@interface seteprop!{K,V}(x::PropertyModule{K,V}, u::VertexID, v::VertexID, props::Dict)
@interface seteprop!{K,V}(x::PropertyModule{K,V}, u::VertexID, v::VertexID, propname, val)

################################################# IMPLEMENTATIONS ##########################################################

# Null Implementation

""" Null property module implementation """
immutable NullModule{K,V} <: PropertyModule{K,V}
end

function NullModule()
   NullModule{Void,Void}()
end

listvprops(g::NullModule) = Void()
listeprops(g::NullModule) = Void()
getvprop(g::NullModule, v::VertexID) = Void()
getvprop(g::NullModule, v::VertexID, propname) = Void()
geteprop(g::NullModule, u::VertexID, v::VertexID) = Void()
geteprop(g::NullModule, u::VertexID, v::VertexID, propname) = Void()
setvprop!(g::NullModule, v::VertexID, props::Dict) = Void()
setvprop!(g::NullModule, v::VertexID, propname, val) = Void()
seteprop!(g::NullModule, u::VertexID, v::VertexID, props::Dict) = Void()
seteprop!(g::NullModule, u::VertexID, v::VertexID, propname, val) = Void()

# NDSparse Implementation
include("ndsparse/propertymodule.jl")

# Dict Implementation
include("dict/propertymodule.jl")