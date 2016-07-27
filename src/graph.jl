################################################# FILE DESCRIPTION #########################################################

# This file contains the core graph definitions.

################################################# IMPORT/EXPORT ############################################################
export
# Types
Graph,
# Typealiases
SimpleGraph, SparseGraph,
# Subgraph
subgraph

type Graph{AM,PM}
   adjmod::AM
   propmod::PM
   labelmod::LabelModule
end

Graph(am, pm, lm=LabelModule(nv(am))) = Graph(am, pm, lm)

adjmod(g::Graph) = g.adjmod
propmod(g::Graph) = g.propmod
labelmod(g::Graph) = g.labelmod

if CAN_USE_LG
   typealias SimpleGraph Graph{LightGraphsAM,VectorPM}
end

typealias SparseGraph Graph{SparseMatrixAM,VectorPM}

################################################# VALIDATION ################################################################

# Vertex validation
validate_vertex(g::Graph, vs) = validate_vertex(adjmod(g), vs)

# Edge checking
can_add_edge(g::Graph, u::VertexID, v::VertexID) = can_add_edge(adjmod(g), u, v)
can_add_edge(g::Graph, es) = can_add_edge(adjmod(g), es)

# Edge validation
validate_edge(g::Graph, u::VertexID, v::VertexID) = validate_edge(adjmod(g), u, v)
validate_edge(g::Graph, es) = validate_edge(adjmod(g), es)

# Property Validation
validate_vertex_property(g::Graph, props) = validate_vertex_property(propmod(g), props)
validate_edge_property(g::Graph, props) = validate_edge_property(propmod(g), props)

################################################# MISC #####################################################################

# Deepcopy
Base.deepcopy(g::Graph) = Graph(deepcopy(adjmod(g)), deepcopy(propmod(g)), deepcopy(labelmod(g)))


################################################# ADJACENCY ################################################################

""" The number of vertices in the graph """
@inline nv(g::Graph) = nv(adjmod(g))

""" The number of edges in the graph """
@inline ne(g::Graph) = ne(adjmod(g))

""" Return V x E """
@inline Base.size(g::Graph) = size(adjmod(g))

""" Return a list of the vertices in the graph """
@inline vertices(g::Graph) = vertices(adjmod(g))

""" Return a list of edge pairs in the graph """
@inline edges(g::Graph) = edges(adjmod(g))

""" Check if vertex v is in the graph """
@inline hasvertex(g::Graph, v::VertexID) = hasvertex(adjmod(g), v)

""" Check if u=>v is in the graph """
@inline hasedge(g::Graph, u::VertexID, v::VertexID) = hasedge(adjmod(g), u, v)
@inline hasedge(g::Graph, es) = hasedge(adjmod(g), es)

""" Vertex v's out-neighbors in the graph (consistency and concurrency unsafe) """
@inline fadj(g::Graph, v::VertexID) = fadj(adjmod(g), v)
""" Vertex v's in-neighbors in the graph (consistency and concurrency unsafe) """
@inline badj(g::Graph, v::VertexID) = badj(adjmod(g), v)

""" Vertex v's out-neighbors in the graph (safe) """
@inline out_neighbors(g::Graph, v::VertexID) = out_neighbors(adjmod(g), v)

""" Vertex v's in-neighbors in the graph (safe) """
@inline in_neighbors(g::Graph, v::VertexID) = in_neighbors(adjmod(g), v)

""" Get the outdegree of a vertex """
@inline outdegree(g::Graph, v::VertexID) = outdegree(adjmod(g), v)

""" Get the indegree of a vertex """
@inline indegree(g::Graph, v::VertexID) = indegree(adjmod(g), v)

################################################# MUTATION ################################################################

""" Add a vertex to the graph """
function addvertex!(g::Graph)
   addvertex!(adjmod(g))
   addvertex!(propmod(g))
   addvertex!(labelmod(g))
end

function addvertex!(g::Graph, l)
   if nv(g) < addvertex!(labelmod(g), l)
      addvertex!(adjmod(g))
      addvertex!(propmod(g))
   end
   resolve(g, l)
end


""" Remove a vertex from the graph """
function rmvertex!(g::Graph, vs::Union{VertexID,AbstractVector{VertexID}})
   validate_vertex(g, vs)
   rmvertex!(adjmod(g), vs); rmvertex!(propmod(g), vs); rmvertex!(labelmod(g), vs)
end


""" Add an edge u->v to the graph """
function addedge!(g::Graph, u::VertexID, v::VertexID)
   can_add_edge(g, u, v)
   addedge!(adjmod(g), u, v); addedge!(propmod(g), u, v)
end

function addedge!(g::Graph, es::Union{EdgeID,AbstractVector{EdgeID}})
   can_add_edge(g, es)
   addedge!(adjmod(g), es); addedge!(propmod(g), es)
end


""" Remove edge u->v from the graph """
function rmedge!(g::Graph, u::VertexID, v::VertexID)
   validate_edge(g, u, v)
   rmedge!(adjmod(g), u, v); rmedge!(propmod(g), u, v)
end

function rmedge!(g::Graph, es::Union{EdgeID,AbstractVector{EdgeID}})
   validate_edge(g, es)
   rmedge!(adjmod(g), es); rmedge!(propmod(g), es)
end

################################################# LIST PROPS ##############################################################

""" Check if a graph has a vertex field """
@inline hasvprop(g::Graph, prop) = hasvprop(propmod(g), prop)

""" Check if a graph has an edge field """
@inline haseprop(g::Graph, prop) = haseprop(propmod(g), prop)

""" List the vertex properties contained in the graph """
@inline listvprops(g::Graph) = listvprops(propmod(g))

""" List the edge properties contained in the graph """
@inline listeprops(g::Graph) = listeprops(propmod(g))


################################################# LABELLING ################################################################

###
# RESOLVE
###
resolve(g::Graph, x) = resolve(labelmod(g), x)
resolve(g::Graph, x, y) = resolve(labelmod(g), x, y)


###
# HALABEL
###
haslabel(g::Graph, x) = haslabel(labelmod(g), x)


###
# ENCODE
###
encode(g::Graph, v::VertexID) = (validate_vertex(g, v); encode(labelmod(g), v))
encode(g::Graph, vs::AbstractVector{VertexID}) = (validate_vertex(g, vs); encode(labelmod(g), vs))

_encode(g::Graph, e::EdgeID) = encode(labelmod(g), e)
_encode(g::Graph, es::AbstractVector{EdgeID}) = encode(labelmod(g), es)

function encode(g::Graph, e::EdgeID)
   validate_edge(g, e)
   _encode(g, e)
end

function encode(g::Graph, es::AbstractVector{EdgeID})
   validate_edge(g, es)
   _encode(g, es)
end

###
# SETLABEL
###
function setlabel!{T}(g::Graph, ls::Vector{T})
   length(ls) == nv(g) || error("Incorrect number of ls provided")
   setlabel!(labelmod(g), ls)
   nothing
end

function setlabel!(g::Graph, propname)
   ls = [getvprop(g, v, propname) for v in vertices(g)]
   setlabel!(labelmod(g), ls)
   nothing
end

function setlabel!(g::Graph)
   setlabel!(labelmod(g))
   nothing
end

function setlabel!(g::Graph, v::VertexID, l)
   validate_vertex(g, v)
   setlabel!(labelmod(g), v, l)
end

function setlabel!(g::Graph, vs::AbstractVector{VertexID}, ls::AbstractVector)
   validate_vertex(g, vs)
   setlabel!(labelmod(g), vs, ls)
end
################################################# DISPLAY ##################################################################

function Base.show{AM,PM}(io::IO, g::Graph{AM,PM})
   write(io, "Graph{$AM,$PM} with $(nv(g)) vertices and $(ne(g)) edges")
end

################################################# SUBGRAPHS ################################################################

subgraph(g::Graph) = deepcopy(g)

# Vertex only
function subgraph(g::Graph, vlist::AbstractVector{VertexID})
   Graph(subgraph(adjmod(g), vlist), subgraph(propmod(g), vlist), subgraph(labelmod(g), vlist))
end

function subgraph(g::Graph, vlist::AbstractVector{VertexID}, vproplist::AbstractVector)
   validate_vertex_property(g, vproplist)
   Graph(subgraph(adjmod(g), vlist), subgraph(propmod(g), vlist, vproplist), subgraph(labelmod(g), vlist))
end

# Edge only
function subgraph(g::Graph, elist::AbstractVector{EdgeID})
   Graph(subgraph(adjmod(g), elist), subgraph(propmod(g), elist), deepcopy(labelmod(g)))
end

function subgraph(g::Graph, elist::AbstractVector{EdgeID}, eproplist::AbstractVector)
   validate_edge_property(g, eproplist)
   Graph(subgraph(adjmod(g), elist), subgraph(propmod(g), elist, eproplist), deepcopy(labelmod(g)))
end

# Vertex and Edge
function subgraph(g::Graph, vlist::AbstractVector{VertexID}, elist::AbstractVector{EdgeID})
   Graph(subgraph(adjmod(g), vlist, elist), subgraph(propmod(g), vlist, elist), subgraph(labelmod(g), vlist))
end

function subgraph(
   g::Graph,
   vlist::AbstractVector{VertexID},
   elist::AbstractVector{EdgeID},
   vproplist::AbstractVector,
   eproplist::AbstractVector
   )
   Graph(
      subgraph(adjmod(g), vlist, elist),
      subgraph(propmod(g), vlist, elist, vproplist, eproplist),
      subgraph(labelmod(g), vlist)
   )
end
