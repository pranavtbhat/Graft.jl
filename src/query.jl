################################################# FILE DESCRIPTION #########################################################

# This file contains methods, macros and operators aimed at providing the user a convenient UI to the graph datastructures
# over the REPL.

################################################# IMPORT/EXPORT ############################################################

export
# Filtering
vertex_filter, edge_filter
################################################# BASICS ###################################################################

# Vertex descriptor and queries
include("query/vertex.jl")

# Edge descriptor and queries
include("query/edge.jl")


# Make the graph type iterable
Base.start(g::Graph) = 1
Base.done(g::Graph, i) = i == 3

function Base.next(g::Graph, i)
   i == 1 && return VertexDescriptor(g), 2
   i == 2 && return EdgeDescriptor(g), 3
   return nothing, 3
end

################################################# VERTEX SUBSETS ############################################################

@inline vertex_subset(g::Graph, vs) = vertex_subset(vertices(g), vs)
@inline vertex_subset(x::VertexDescriptor, vs) = vertex_subset(x.g, vertex_subset(x.vs, vs))

@inline vertex_subset(::Colon, vs) = vs
@inline vertex_subset(::Colon, ::Colon) = Colon()
@inline vertex_subset(v::VertexID, ::Colon) = v
@inline vertex_subset(v1::VertexID, v2) = v1 == v2 ? v2 : error("Invalid vertex indexing: $v1 <- $v2")
@inline vertex_subset(vs::AbstractVector{VertexID}, ::Colon) = deepcopy(vs)
@inline vertex_subset(vs::AbstractVector{VertexID}, v::VertexID) = in(v, vs) ? v : error("Invalid vertex indexing: $vs <- $v")
@inline vertex_subset(vs1::AbstractVector{VertexID}, vs2::AbstractVector{VertexID}) = issubset(vs2, vs1) ? vs2 : error("Invalid vertex indexing: $vs2 <- $vs1")


################################################# EDGE SUBSETS ##############################################################

@inline edge_subset(g::Graph, is) = edge_subset(edges(g), is)
@inline edge_subset(x::EdgeDescriptor, is) = edge_subset(x.es, is)

@inline edge_subset(e::EdgeID, ::Colon) = e
@inline edge_subset(e1::EdgeID, e2::EdgeID) = e1 == e2 ? e2 : error("Invalid edge indexing: $e1 <- $e2")
@inline edge_subset(e::EdgeID, i) = i == 1 ? e : error("Invalid edge indexing: $e <- $i")

@inline edge_subset(es::AbstractVector{EdgeID}, ::Colon) = deepcopy(es)
@inline edge_subset(es::AbstractVector{EdgeID}, e::EdgeID) = e in es ? e : error("Invalid edge indexing: $es <- $e")
function edge_subset(es::AbstractVector{EdgeID}, is)
   try
      es[is]
   catch
      error("Invalid edge indexing: $es <- $is")
   end
end


################################################# PROPERTY SUBSETS ##########################################################

@inline property_subset(g::Graph, props) = property_subset(listvprops(g), props)
@inline property_subset(x::EdgeDescriptor, props) = property_subset(x.props, props)

@inline property_subset(::Colon, props) = props
@inline property_subset(::Colon, ::Colon) = Colon()

@inline _property_subset(prop, ::Colon) = deepcopy(prop)
@inline _property_subset(prop1, prop2) = prop1 == prop2 ? prop2 : error("Invalid property indexing $prop1 <- $prop2")
@inline _property_subset(prop, props::AbstractVector) = error("Invalid property indexing $prop <- $props")
@inline property_subset(p1, p2) = _property_subset(p1, p2) # Ambiguity fix

@inline property_subset(props::AbstractVector, prop) = in(prop, props) ? prop : error("Invalid property indexing $props <- $prop")
@inline property_subset(props1::AbstractVector, props2::AbstractVector) = issubset(props2, props1) ? props2 : error("Invalid property indexing $props1 <- $props2")
@inline property_subset(props::AbstractVector, ::Colon) = deepcopy(props)
