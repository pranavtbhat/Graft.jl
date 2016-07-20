################################################# FILE DESCRIPTION #########################################################

# This file contains methods, macros and operators aimed at providing the user a convenient UI over the REPL

################################################# IMPORT/EXPORT ############################################################

export
# Types
VertexDescriptor, EdgeDescriptor,
# Macros
@query
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

macro query(desc, x)
   quer = Expr(:quote, x)
   quote
      local V = $(esc(desc))
      local Q = $(esc(quer))
      exec_query(Q, V)
   end
end
