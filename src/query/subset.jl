################################################# FILE DESCRIPTION #########################################################

# This file contains methods to faciliate the construction of subset descriptors

################################################# IMPORT/EXPORT ############################################################

################################################# VERTEX SUBSETS ############################################################

@inline vertex_subset(g::Graph, vs) = vertex_subset(vertices(g), vs)
@inline vertex_subset(x::VertexDescriptor, vs) = vertex_subset(x.g, vertex_subset(x.vs, vs))

@inline vertex_subset(vs::AbstractVector{VertexID}, ::Colon) = copy(vs)
@inline vertex_subset(vs::AbstractVector{VertexID}, v::VertexID) = in(v, vs) ? [v] : error("Invalid vertex indexing: $vs <- $v")
@inline vertex_subset(vs1::AbstractVector{VertexID}, vs2::AbstractVector{VertexID}) = issubset(vs2, vs1) ? vs2 : error("Invalid vertex indexing: $vs2 <- $vs1")


################################################# EDGE SUBSETS ##############################################################

@inline edge_subset(g::Graph, is) = edge_subset(edges(g), is)
@inline edge_subset(x::EdgeDescriptor, is) = edge_subset(x.es, is)

@inline edge_subset(es::AbstractVector{EdgeID}, ::Colon) = copy(es)
@inline edge_subset(es::AbstractVector{EdgeID}, i::Int) = try [es[i]] catch error("Invalid edge indexing: $es <- $i") end
@inline edge_subset(es::AbstractVector{EdgeID}, is) = try es[is] catch error("Invalid edge indexing: $es <- $is") end

@inline edge_subset(es::AbstractVector{EdgeID}, e::EdgeID) = e in es ? [e] : error("Invalid edge indexing: $es <- $e")
@inline edge_subset(es1::AbstractVector{EdgeID}, es2::AbstractVector{EdgeID}) = issubset(es2, es1) ? es2 : error("Invalid edge indexing: $es1 <- $es2")

################################################# PROPERTY SUBSETS ##########################################################

@inline property_subset(g::Graph, props) = property_subset(listvprops(g), props)
@inline property_subset(x::VertexDescriptor, props) = property_subset(x.props, props)
@inline property_subset(x::EdgeDescriptor, props) = property_subset(x.props, props)

@inline property_subset(props::AbstractVector, prop) = in(prop, props) ? [prop] : error("Invalid property indexing $props <- $prop")
@inline property_subset(props1::AbstractVector, props2::AbstractVector) = issubset(props2, props1) ? props2 : error("Invalid property indexing $props1 <- $props2")
@inline property_subset(props::AbstractVector, ::Colon) = copy(props)
