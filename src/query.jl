################################################# FILE DESCRIPTION #########################################################

# This file contains methods, macros and operators aimed at providing the user a convenient UI over the REPL

################################################# IMPORT/EXPORT ############################################################

export
# Types
VertexDescriptor, EdgeDescriptor,
# Macros
@query, @filter,
# Methods
set!
################################################# BASICS ###################################################################

""" Describes a subset of vertices and their properties """
type VertexDescriptor
   g::Graph
   vs::AbstractVector{VertexID}
   props::Vector
   parent::Union{Void,VertexDescriptor}
end

""" Describes a subset of vertices and their properties """
type EdgeDescriptor
   g::Graph
   es::AbstractVector{EdgeID}
   props::Vector
   parent::Union{Void,EdgeDescriptor}
end


# Graph structural queries
include("query/graph.jl")

# Descriptor subsets
include("query/subset.jl")

# Vertex descriptor implementation
include("query/vertex.jl")

# Edge descriptor implementation
include("query/edge.jl")

# Query execution
include("query/exec.jl")

################################################# @QUERY #####################################################################

type QueryNode
   expr
end

macro query(desc, x)
   x = Expr(:quote, x)
   quote
      local Q = $(esc(x))
      local D = $(esc(desc))
      exec_query(Q, D)
   end
end

macro query(x)
   QueryNode(x)
end

|>(desc, x::QueryNode) = exec_query(x.expr, desc)

################################################# @FILTER #####################################################################

type FilterNode
   expr
end

macro filter(desc, x)
   x = Expr(:quote, x)
   quote
      local Q = $(esc(x))
      local D = $(esc(desc))
      _filter(exec_query(Q, D), D)
   end
end

macro filter(x)
   FilterNode(x)
end

|>(desc, x::FilterNode) = _filter(exec_query(x.expr, desc), desc)
