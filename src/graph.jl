################################################# FILE DESCRIPTION #########################################################

# This file contains the core graph definitions.

################################################# IMPORT/EXPORT ############################################################
export
# Types
Graph,
# Typealiases
SimpleGraph,
# Subgraph
subgraph

type Graph{AM,PM}
   adjmod::AM
   propmod::PM

   function Graph(am::AdjacencyModule, pm::PropertyModule)
      self = new()
      self.adjmod = am
      self.propmod = pm
      self
   end

   function Graph(nv::Int=0)
      self = new()
      self.adjmod = AM(nv)
      self.propmod = PM()
      self
   end

   function Graph(nv::Int, ne::Int)
      self = new()
      self.adjmod = AM(nv, ne)
      self.propmod = PM()
      self
   end
end

@inline adjmod(g::Graph) = g.adjmod
@inline propmod(g::Graph) = g.propmod


typealias SimpleGraph Graph{LightGraphsAM,DictPM{ASCIIString,Any}}


################################################# GRAPH API ############################################################

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

""" Check if u=>v is in the graph """
@inline hasedge(g::Graph, u::VertexID, v::VertexID) = hasedge(adjmod(g), u, v)

""" Vertex v's out-neighbors in the graph """
@inline fadj(g::Graph, v::VertexID) = fadj(adjmod(g), v)

""" Vertex v's in-neighbors in the graph """
@inline badj(g::Graph, v::VertexID) = badj(adjmod(g), v)

""" Add a vertex to the graph """
function addvertex!(g::Graph)
   addvertex!(adjmod(g))
   addvertex!(propmod(g))
end

""" Remove a vertex from the graph """
function rmvertex!(g::Graph, v::VertexID)
   rmvertex!(adjmod(g), v)
   rmvertex!(propmod(g), v)
end

""" Add an edge u->v to the graph """
function addedge!(g::Graph, u::VertexID, v::VertexID)
   addedge!(adjmod(g), u, v)
   addedge!(propmod(g), u, v)
end

""" Remove edge u->v from the graph """
function rmedge!(g::Graph, u::VertexID, v::VertexID)
   rmedge!(adjmod(g), u, v)
   rmedge!(propmod(g), u, v)
end

""" List the vertex properties contained in the graph """
@inline listvprops(g::Graph) = listvprops(propmod(g))

""" List the edge properties contained in the graph """
@inline listeprops(g::Graph) = listeprops(propmod(g))

""" Return the properties of a particular vertex in the graph """
@inline getvprop(g::Graph, v::VertexID) = getvprop(propmod(g), v)
@inline getvprop(g::Graph, v::VertexID, prop) = getvprop(propmod(g), v, prop)

""" Return the properties of a particular edge in the graph """
@inline geteprop(g::Graph, u::VertexID, v::VertexID) = geteprop(propmod(g), u, v)
@inline geteprop(g::Graph, u::VertexID, v::VertexID, prop) = geteprop(propmod(g), u, v, prop)

""" Set the value for a vertex property """
@inline setvprop!(g::Graph, v::VertexID, props::Dict) = setvprop!(propmod(g), v, props)
@inline setvprop!(g::Graph, v::VertexID, prop, val) = setvprop!(propmod(g), v, prop, val)

function setvprop!(g::Graph, propname, vals::Vector)
   length(vals) == nv(g) || error("Length of values supplied must equal the number of vertices in the graph")
   x = propmod(g)
   for v in 1 : nv(g)
      setvprop!(x, v, propname, vals[v])
   end
end

function setvprop!(g::Graph, propname, f::Function)
   x = propmod(g)
   for v in 1 : nv(g)
      setvprop!(x, v, propname, f(v))
   end
end


""" Set the value for an edge property """
@inline seteprop!(g::Graph, u::VertexID, v::VertexID, props::Dict) = seteprop!(propmod(g), u, v, props)
@inline seteprop!(g::Graph, u::VertexID, v::VertexID, prop, val) = seteprop!(propmod(g), u, v, prop, val)

function seteprop!(g::Graph, propname, f::Function)
   x = propmod(g)
   for (u,v) in edges(g)
      seteprop!(x, u, v, propname, f(u,v))
   end
end

################################################# DISPLAY ##################################################################

function Base.show{AM,PM}(io::IO, g::Graph{AM,PM})
   write(io, "Graph{$AM,$PM} with $(nv(g)) vertices and $(ne(g)) edges")
end

################################################# SUBGRAPHS ################################################################

""" Construct an induced subgraph containing the vertices provided """
function subgraph{AM,PM}(g::Graph{AM,PM}, vlist::AbstractVector{VertexID})
   Graph{AM,PM}(subgraph(adjmod(g), vlist), subgraph(propmod(g), vlist))
end
