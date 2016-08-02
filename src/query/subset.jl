################################################# FILE DESCRIPTION #########################################################

# This file contains methods to faciliate the construction of subset descriptors

################################################# IMPORT/EXPORT ############################################################

################################################# VERTEX SUBSETS ############################################################

vertex_subset(g::Graph, vs) = vertex_subset(vertices(g), vs)
vertex_subset(x::VertexDescriptor, vs) = vertex_subset(x.g, vertex_subset(x.vs, vs))

vertex_subset(vs::AbstractVector{VertexID}, ::Colon) = copy(vs)
vertex_subset(vs::AbstractVector{VertexID}, v::VertexID) = in(v, vs) ? [v] : error("Invalid vertex indexing: $vs <- $v")
vertex_subset(vs1::AbstractVector{VertexID}, vs2::AbstractVector{VertexID}) = vs2


################################################# EDGE SUBSETS ##############################################################

edge_subset(g::Graph, is) = edge_subset(edges(g), is)
edge_subset(x::EdgeDescriptor, is) = edge_subset(x.es, is)


###
# SINGLE
###
edge_subset(es::AbstractVector{EdgeID}, i::Int) = try [es[i]] catch error("Invalid edge indexing: $es <- $i") end

###
# MULTI INDEX
###
edge_subset(es::AbstractVector{EdgeID}, ::Colon) = copy(es)
edge_subset(es::AbstractVector{EdgeID}, is) = try es[is] catch error("Invalid edge indexing: $es <- $is") end
edge_subset(es::EdgeIter, is) = try collect(es)[is] catch error("Invalid edge indexing: #es <- $is") end

###
# SINGLE EDGE
###
edge_subset(es::AbstractVector{EdgeID}, e::EdgeID) = e in es ? [e] : error("Invalid edge indexing: $es <- $e")

###
# MUTLI EDGE
###
# SKIP THIS CHECK. It's ridiculously expensive...
edge_subset(es1::AbstractVector{EdgeID}, es2::AbstractVector{EdgeID}) = es2

################################################# PROPERTY SUBSETS ##########################################################

property_subset(g::Graph, props) = property_subset(listvprops(g), props)
property_subset(x::VertexDescriptor, props) = property_subset(x.props, props)
property_subset(x::EdgeDescriptor, props) = property_subset(x.props, props)

property_subset(props::AbstractVector, prop) = in(prop, props) ? [prop] : error("Invalid property indexing $props <- $prop")
property_subset(props1::AbstractVector, props2::AbstractVector) = issubset(props2, props1) ? props2 : error("Invalid property indexing $props1 <- $props2")
property_subset(props::AbstractVector, ::Colon) = copy(props)
