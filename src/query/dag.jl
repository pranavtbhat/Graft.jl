################################################# FILE DESCRIPTION #########################################################

# This file contains definitions for VertexNodes in the query dag.

################################################# IMPORT/EXPORT ############################################################

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

###
# Denotes a vertex or edge property
###
abstract Property <: Node

################################################# GRAPHNODE ################################################################

###
# Leaf node containing a symbol denoting a graph object.
###
immutable SimpleGraphNode <: GraphNode
   gs::Symbol
end

Base.show(io::IO, x::SimpleGraphNode) = write(io, "Graph($(x.gs))")

###
# Node denoting a filter on vertices, determined by an array of booleans.
###
immutable FilterNode <: GraphNode
   graph::GraphNode
   bools::VectorNode
end

Base.show(io::IO, x::FilterNode) = write(io, "filter($(x.graph), $(x.bools))")

###
# Node denoting a subset of either vertex properties, or edge properties, or subsets of both.
###
immutable SelectNode <: GraphNode
   graph::GraphNode
   props::Vector{Property}
end

Base.show(io::IO, x::SelectNode) = write(io, "select($(x.props),$(x.graph))")

################################################# VECTORNODE ###############################################################

###
# Denotes a single literal value to be broadcast.
###
immutable LiteralNode{T} <: VectorNode
   val::T
end

Base.show{T}(io::IO, x::LiteralNode{T}) = write(io, "$(x.val)")

###
# Denotes a column from the vertex or edge dataframes
###
immutable TableNode <: VectorNode
   graph::GraphNode
   prop::Property
end

Base.show(io::IO, x::TableNode) = write(io, "Property($(x.graph), $(x.prop))")

###
# Denotes an operation to be performed on two vectors
###
immutable VectorOperation <: VectorNode
   op::Function
   args::Vector{VectorNode}
end

Base.show(io::IO, x::VectorOperation) = write(io, "{$(x.op)($(x.args))}")

################################################# PROPERTY #################################################################

###
# A vertex property
###
immutable VertexProperty <: Property
   prop::Symbol
end

Base.show(io::IO, x::VertexProperty) = write(io, "v.$(x.prop)")

###
# An edge property
###
immutable EdgeProperty <: Property
   prop::Symbol
end

Base.show(io::IO, x::EdgeProperty) = write(io, "e.$(x.prop)")

###
# An edge source vertex property
###
immutable EdgeSourceProperty <: Property
   prop::Symbol
end

Base.show(io::IO, x::EdgeSourceProperty) = write(io, "s.$(x.prop)")

###
# An edge target vertex property
###
immutable EdgeTargetProperty <: Property
   prop::Symbol
end

Base.show(io::IO, x::EdgeTargetProperty) = write(io, "t.$(x.prop)")
