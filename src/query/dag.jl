################################################# FILE DESCRIPTION #########################################################

# This file contains definitions for VertexNodes in the query dag.

################################################# IMPORT/EXPORT ############################################################

export
# Abstract Nodes
Node,
QueryNode,
FilterNode,


# Internal Nodes
VertexQueryNode,
EdgeQueryNode,

VertexDataNode,
EdgeDataNode,

VertexTableNode,
EdgeTableNode,

VertexFilterNode,
EdgeFilterNode,


# Abstract Leaf Nodes
Operation, VertexOperation, EdgeOperation,

# Leaf Nodes
GraphNode, DataNode


###
# ABSTRACT TYPES
###
abstract Node
abstract Operation

# An internal node that returns data (array or dataframe)
abstract QueryNode <: Node

# An internal node that returns a graph
abstract FilterNode <: Node

# An operation to be applied on vertex properties
abstract VertexOperation <: Operation

# An operation to be applied on edge properties
abstract EdgeOperation <: Operation

###
# INTERNAL NODES
###

# An internal node that returns Vertex Data
type VertexQueryNode <: QueryNode
   lhs::QueryNode
   op::VertexOperation
   rhs::QueryNode
end

# An internal node that returns Edge Data
type EdgeQueryNode <: QueryNode
   lhs::QueryNode
   op::EdgeOperation
   df::QueryNode
end

# An internal node that returns an array of vertex properties
type VertexDataNode <: QueryNode
   g::Graph
   vprop::Symbol
end

# An internal node that returns an array of edge properties
type EdgeDataNode <: QueryNode
   g::Graph
   eprop::Symbol
end

# An internal node that returns a table of vertex properties
type VertexTableNode <: QueryNode
   g::Graph
   vprops::Union{Colon, Vector{Symbol}}
end

# An internal node that returns a table of edge properties
type EdgeTableNode <: QueryNode
   g::Graph
   eprops::Union{Colon, Vector{Symbol}}
end

# An internal node that returns a graph
type VertexFilterNode <: FilterNode
   g::FilterNode
   op::VertexOperation
   df::QueryNode
end

# An internal node that returns a graph
type EdgeFilterNode <: FilterNode
   g::FilterNode
   op::EdgeOperation
   df::QueryNode
end


###
# LEAF NODES
###

# A leaf node that simply returns a graph
type GraphNode <: FilterNode
   g::Graph
end

# A leaf node that returns a FakeVector
type DataNode <: QueryNode
   literal
end
