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
   labelmod::Any


   function Graph(am, pm=NullModule(), lm=NullModule())
      self = new()
      self.adjmod = am
      self.propmod = pm
      self.labelmod = lm
      self
   end

   function Graph(nv::Int=0)
      self = new()
      self.adjmod = AM(nv)
      self.propmod = PM(nv)
      self.labelmod = NullModule()
      self
   end

   function Graph(nv::Int, ne::Int)
      self = new()
      self.adjmod = AM(nv, ne)
      self.propmod = PM(nv)
      self.labelmod = NullModule()
      self
   end
end

@inline adjmod(g::Graph) = g.adjmod
@inline propmod(g::Graph) = g.propmod
@inline labelmod(g::Graph) = g.labelmod

if CAN_USE_LG
   typealias SimpleGraph Graph{LightGraphsAM,DictArrPM}
end

typealias SparseGraph Graph{SparseMatrixAM, DictArrPM}

################################################# HELPERS ##############################################################

function validate_vertex(g::Graph, v::VertexID)
   hasvertex(g, v) || error("Vertex $v isn't in the graph")
   nothing
end

function validate_vertex(g::Graph, vlist::AbstractVector{VertexID})
   for v in vlist
      validate_vertex(g, v)
   end
   nothing
end

function can_add_edge(g::Graph, u::VertexID, v::VertexID)
   validate_vertex(g, u)
   validate_vertex(g, v)
   nothing
end

@inline can_add_edge(g::Graph, e::EdgeID) = can_add_edge(g, e...)

function can_add_edge(g::Graph, elist::AbstractVector{EdgeID})
   for (u,v) in elist
      can_add_edge(g, u, v)
   end
end

function validate_edge(g::Graph, u::VertexID, v::VertexID)
   hasedge(g, u, v) || error("Edge $u=>$v isn't in the graph")
   nothing
end

function validate_edge(g::Graph, e::EdgeID)
   hasedge(g, e) || error("Edge $(e.first)=>$(e.second) isn't in the graph")
   nothing
end

function validate_edge(g::Graph, elist::AbstractVector{EdgeID})
   for e in elist
      validate_edge(g, e)
   end
   nothing
end
################################################# GRAPH API ############################################################

# Deepcopy
Base.deepcopy{AM,PM}(g::Graph{AM,PM}) = Graph{AM,PM}(deepcopy(adjmod(g)), deepcopy(propmod(g)), deepcopy(labelmod(g)))



# Adjacency
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
@inline hasedge(g::Graph, e::EdgeID) = hasedge(adjmod(g), e)

""" Vertex v's out-neighbors in the graph """
@inline fadj(g::Graph, v::VertexID) = fadj(adjmod(g), v)

""" Vertex v's in-neighbors in the graph """
@inline badj(g::Graph, v::VertexID) = badj(adjmod(g), v)

""" Get the outdegree of a vertex """
@inline outdegree(g::Graph, v::VertexID) = outdegree(adjmod(g), v)

""" Get the indegree of a vertex """
@inline indegree(g::Graph, v::VertexID) = indegree(adjmod(g), v)


""" Add a vertex to the graph """
function addvertex!(g::Graph, num::Int=1)
   addvertex!(adjmod(g), num)
   addvertex!(propmod(g), num)
   addvertex!(labelmod(g), num)
end

""" Remove a vertex from the graph """
function rmvertex!(g::Graph, vs::Union{VertexID,AbstractVector{VertexID}})
   validate_vertex(g, vs)
   rmvertex!(adjmod(g), vs)
   rmvertex!(propmod(g), vs)
   rmvertex!(labelmod(g), vs)
end

""" Add an edge u->v to the graph """
function addedge!(g::Graph, u::VertexID, v::VertexID)
   can_add_edge(g, u, v)
   addedge!(adjmod(g), u, v)
   addedge!(propmod(g), u, v)
end

function addedge!(g::Graph, es::Union{EdgeID,AbstractVector{EdgeID}})
   can_add_edge(g, es)
   addedge!(adjmod(g), es)
   addedge!(propmod(g), es)
end

""" Remove edge u->v from the graph """
function rmedge!(g::Graph, u::VertexID, v::VertexID)
   validate_edge(g, u, v)
   rmedge!(adjmod(g), u, v)
   rmedge!(propmod(g), u, v)
end

function rmedge!(g::Graph, es::Union{EdgeID,AbstractVector{EdgeID}})
   validate_edge(g, es)
   rmedge!(adjmod(g), es)
   rmedge!(propmod(g), es)
end


# Properties
""" List the vertex properties contained in the graph """
@inline listvprops(g::Graph) = listvprops(propmod(g))

""" List the edge properties contained in the graph """
@inline listeprops(g::Graph) = listeprops(propmod(g))



""" Return the properties of a particular vertex(s) in the graph """
function getvprop(g::Graph, vs::Union{VertexID,AbstractVector{VertexID}})
   validate_vertex(g, vs)
   getvprop(propmod(g), vs)
end
getvprop(g::Graph, ::Colon) = getvprop(propmod(g), vertices(g))

function getvprop(g::Graph, vs::Union{VertexID,AbstractVector{VertexID}}, propname)
   validate_vertex(g, vs)
   getvprop(propmod(g), vs, propname)
end
getvprop(g::Graph, ::Colon, propname) = getvprop(propmod(g), vertices(g), propname)

""" Return the properties of a particular edge in the graph """
function geteprop(g::Graph, u::VertexID, v::VertexID)
   validate_edge(g, u, v)
   geteprop(propmod(g), u, v)
end

function geteprop(g::Graph, es::Union{EdgeID,AbstractVector{EdgeID}})
   validate_edge(g, es)
   geteprop(propmod(g), es)
end
geteprop(g::Graph, ::Colon) = geteprop(propmod(g), collect(edges(g)))

function geteprop(g::Graph, u::VertexID, v::VertexID, prop)
   validate_edge(g, u, v)
   geteprop(propmod(g), u, v, prop)
end

function geteprop(g::Graph, es::Union{EdgeID,AbstractVector{EdgeID}}, propname)
   validate_edge(g, es)
   geteprop(propmod(g), es, propname)
end
geteprop(g::Graph, ::Colon, propname) = geteprop(propmod(g), collect(edges(g)), propname)


""" Set the value for a vertex property """
function setvprop!(g::Graph, vlist::Union{VertexID,AbstractVector{VertexID}}, dlist::Union{Dict,Vector})
   validate_vertex(g, vlist)
   setvprop!(propmod(g), vlist, dlist)
end
@inline setvprop!(g::Graph, ::Colon, dlist::Vector) = setvprop!(propmod(g), vertices(g), dlist)

function setvprop!(g::Graph, vs::Union{VertexID,AbstractVector{VertexID}}, val, propname)
   validate_vertex(g, vs)
   setvprop!(propmod(g), vs, val, propname)
end

function setvprop!(g::Graph, vlist::AbstractVector{VertexID}, f::Function, propname)
   validate_vertex(g, vlist)
   setvprop!(propmod(g), vlist, f, propname)
end

function setvprop!(g::Graph, ::Colon, vals::Vector, propname)
   setvprop!(propmod(g), :, vals, propname)
end

function setvprop!(g::Graph, ::Colon, f::Function, propname)
   setvprop!(propmod(g), :, f, propname)
end


""" Set the value for an edge property """
function seteprop!(g::Graph, u::VertexID, v::VertexID, d::Dict)
   validate_edge(g, u, v)
   seteprop!(propmod(g), u, v, d)
end

function seteprop!(g::Graph, es::EdgeID, ds::Dict)
   validate_edge(g, es)
   seteprop!(propmod(g), es, ds)
end

function seteprop!(g::Graph, es::AbstractVector{EdgeID}, ds::Vector)
   validate_edge(g, es)
   length(es) == length(ds) || error("Number of edges doesn't equal number of values")
   seteprop!(propmod(g), es, ds)
end
@inline seteprop!(g::Graph, ::Colon, ds::Vector) = seteprop!(propmod(g), collect(edges(g)), ds)

function seteprop!(g::Graph, u::VertexID, v::VertexID, val, propname)
   validate_edge(g, u, v)
   seteprop!(propmod(g), u, v, val, propname)
end

function seteprop!(g::Graph, es::Union{EdgeID,AbstractVector{EdgeID}}, val, propname)
   validate_edge(g, es)
   length(es) == length(val) || error("Number of edges doesn't equal number of values")
   seteprop!(propmod(g), es, val, propname)
end

function seteprop!(g::Graph, elist::AbstractVector{EdgeID}, f::Function, propname)
   validate_edge(g, elist)
   seteprop!(propmod(g), elist, f, propname)
end

function seteprop!(g::Graph, ::Colon, vals::Vector, propname)
   ne(g) == length(vals) || error("Number of edges doesn't equal number of values")
   seteprop!(propmod(g), :, collect(edges(g)), vals, propname)
end

function seteprop!(g::Graph, ::Colon, f::Function, propname)
   seteprop!(propmod(g), :, collect(edges(g)), f, propname)
end


# Labelling
resolve(g::Graph, x) = resolve(labelmod(g), x)

function encode(g::Graph, v::Union{VertexID,AbstractVector{VertexID}})
   validate_vertex(g, v)
   encode(labelmod(g), v)
end

function encode(g::Graph, elist::Union{EdgeID,AbstractVector{EdgeID}})
   validate_edge(g, elist)
   encode(labelmod(g), elist)
end

function setlabel!{T}(g::Graph, labels::Vector{T})
   length(labels) == nv(g) || error("Incorrect number of labels provided")
   g.labelmod = LabelModule(labels)
   nothing
end

function setlabel!(g::Graph, f::Function)
   labels = [f(v) for v in vertices(g)]
   g.labelmod = LabelModule(labels)
   nothing
end

function setlabel!(g::Graph, propname)
   labels = [getvprop(g, v, propname) for v in vertices(g)]
   g.labelmod = LabelModule(labels)
   nothing
end

function setlabel!(g::Graph, v::VertexID, label)
   validate_vertex(g, v)
   setlabel!(labelmod(g), v, label)
end

################################################# DISPLAY ##################################################################

function Base.show{AM,PM}(io::IO, g::Graph{AM,PM})
   write(io, "Graph{$AM,$PM} with $(nv(g)) vertices and $(ne(g)) edges")
end

################################################# SUBGRAPHS ################################################################

""" Construct an induced subgraph containing the vertices provided """
function subgraph{AM,PM}(g::Graph{AM,PM}, vlist::AbstractVector{VertexID})
   Graph{AM,PM}(subgraph(adjmod(g), vlist), subgraph(propmod(g), vlist), subgraph(labelmod(g), vlist))
end

""" Construct a subgraph from a list of edges """
function subgraph{AM,PM}(g::Graph{AM,PM}, elist::AbstractVector{EdgeID})
   Graph{AM,PM}(subgraph(adjmod(g), elist), subgraph(propmod(g), elist), subgraph(labelmod(g), elist))
end