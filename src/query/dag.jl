################################################# FILE DESCRIPTION #########################################################

# This file contains definitions for VertexNodes in the query dag.

################################################# IMPORT/EXPORT ############################################################

export Node, LiteralNode

###
# A Part of the DAG. The execution of a node returns
# a value which may be used higher up in the dag
###
abstract Node

###
# Denotes a Graph
###
abstract GraphNode <: Node

###
# Denotes a vector of values
###
abstract VectorNode <: Node

################################################# GRAPHNODE ################################################################

###
# Leaf node containing a graph
###
immutable SimpleGraphNode <: GraphNode
   g::Graph
end

Base.show(io::IO, x::SimpleGraphNode) = write(io, "Graph($(nv(x.g)),$(ne(x.g)))")

###
# Node denoting a filter on vertices, determined by an array of booleans.
###
immutable VertexFilterNode <: GraphNode
   g::GraphNode
   bools::VectorNode
end

################################################# LITERALNODE ##############################################################


###
# Denotes a single literal value.
###
immutable LiteralNode{T} <: Node
   val::T
end

Base.show{T}(io::IO, x::LiteralNode{T}) = write(io, "Lt{$T}($(x.val))")


################################################# VECTORNODE ###############################################################

###
# Denotes a column from the Vertex DataFrame
###
immutable VertexPropertyNode <: VectorNode
   graph::GraphNode
   vprop::Symbol
end

Base.show(io::IO, x::VertexPropertyNode) = write(io, "Vprop($(x.graph), $(x.vprop))")

###
# Denotes a column from the Edge DataFrame
###
immutable EdgePropertyNode <: VectorNode
   graph::GraphNode
   eprop::Symbol
end

Base.show(io::IO, x::EdgePropertyNode) = write(io, "Eprop($(x.graph), $(x.eprop))")
