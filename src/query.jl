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

################################################# ADJACENCY QUERIES #########################################################

function Base.getindex(g::Graph, v::VertexID)
   validate_vertex(g, v)
   copy(fadj(g, v))
end

function Base.getindex(g::Graph, v)
   v = resolve(g, v)
   getindex(g, v)
end


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

################################################# SUBGRAPHING ################################################################

Graph(x::VertexDescriptor) = subgraph(x.g, x.vs, x.props)

Graph(x::EdgeDescriptor) = subgraph(x.g, x.es, x.props)

# Pray that they were derived from the same graphs :P
function Graph(V::VertexDescriptor, E::EdgeDescriptor)
   g = V.g
   vlist = V.vs
   elist = E.es
   vproplist = V.props
   eproplist = E.props

   am = subgraph(adjmod(g), vlist, elist)
   pm = subgraph(propmod(g), vlist, elist, vproplist, eproplist)
   lm = subgraph(labelmod(g), vlist)

   Graph(am, pm, lm)
end
