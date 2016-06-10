################################################# FILE DESCRIPTION #########################################################

# This file contains graph typealiases and random graph generation methods.

################################################# IMPORT/EXPORT ############################################################
export
# Typealiases
SimpleGraph,
# Random Generation
random_vertex_prop!, random_edge_prop!,
# Subgraph
subgraph

################################################# TYPE ALIASES #############################################################

typealias SimpleGraph Graph{LightGraphsAM,DictPM{ASCIIString,Any}}

################################################# RANDOM PROPERTIES ########################################################


function random_vertex_prop!(g::Graph, propname, f::Function)
   map(v -> random_vertex_prop!(propmod(g), v, propname, f), 1 : nv(g))
   nothing
end

function random_vertex_prop!(g::Graph, d::Dict)
   for (propname,f) in d
      random_vertex_prop!(g, propname, f)
   end
end

function random_vertex_prop!(g::Graph)
   random_vertex_prop!(g, "label", randstring)
end

function random_edge_prop!(g::Graph, propname, f::Function)
   pm = propmod(g)
   for u in 1 : nv(g)
      for v in fadj(g, u)
         random_edge_prop!(pm, u, v, propname, f)
      end
   end
end

function random_edge_prop!(g::Graph)
   random_edge_prop!(g, "weight", () -> rand(Int))
end

################################################# DISPLAY ##################################################################

function Base.show{AM,PM}(io::IO, g::Graph{AM,PM})
   write(io, "Graph{$AM,$PM} with $(nv(g)) vertices and $(ne(g)) edges")
end

################################################# SUBGRAPHS ################################################################

function subgraph{AM,PM}(g::Graph{AM,PM}, vlist::AbstractVector{VertexID})
   sg = Graph{AM,PM}()
   sg.adjmod = subgraph(adjmod(g), vlist)
   sg.propmod = subgraph(propmod(g), vlist)
   sg
end
