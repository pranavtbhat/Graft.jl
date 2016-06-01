################################################# FILE DESCRIPTION #########################################################

# This file contains subtypes of the LGSparseGraph type. The graph type relies on LightGraphs.DiGraph to store adjacency
# information, and uses n-dimensional sparse arrays to store property information. 

################################################# IMPORT/EXPORT ############################################################

export
# Types
LGSparseGraph

""" A consolidated Sparse Graph that leverages LightGraphs.jl """
type LGSparseGraph <: SparseGraph
   lg::LightGraphs.DiGraph                               # LightGraphs datastructure
   data::SparseArray                                     # Store all the data involved
   pmap::PropertyMap                                     # Vertex/Edge property map
end

################################################# SPARSE GRAPH INTERFACE ###################################################

@inline data(g::LGSparseGraph) = g.data

@inline pmap(g::LGSparseGraph) = g.pmap

################################################# CONSTRUCTION INTERFACE ###################################################

function emptygraph(::Type{LGSparseGraph}, num_verices::Int = 0)
   lg = LightGraphs.DiGraph(num_verices)
   D = NDSparse((MAX_EDGE, MAX_EDGE), Int[], Int[], Int[], WithDefault(Any[], nothing))
   LGSparseGraph(lg, D, PropertyMap())
end

################################################# BASIC GRAPH INTERFACE ####################################################

nv(g::LGSparseGraph) = LightGraphs.nv(g.lg)

ne(g::LGSparseGraph) = LightGraphs.ne(g.lg)

Base.size(g::LGSparseGraph) = (nv(g), ne(g))

function fadj(g::LGSparseGraph, v::VertexID)
   copy(LightGraphs.fadj(g.lg, v))
end

function badj(g::LGSparseGraph, v::VertexID)
   copy(LightGraphs.badj(g.lg, v))
end

function addvertex!(g::LGSparseGraph)
   LightGraphs.add_vertex!(g.lg)
   nothing
end

function addvertex!{K<:PropName,V<:Any}(g::LGSparseGraph, props::Dict{K,V})
   LightGraphs.add_vertex!(g.lg)
   setvprop!(g, nv(g), props)
   nothing
end

function addedge!(g::LGSparseGraph, u::VertexID, v::VertexID)
   # LGSparseGraph doesn't use the x,y,1 entry to indicate edges.
   LightGraphs.add_edge!(g.lg, u, v)
   nothing
end

function addedge!{K<:PropName,V<:Any}(g::LGSparseGraph, u::VertexID, v::VertexID, props::Dict{K,V})
   LightGraphs.add_edge!(g.lg, u, v)
   seteprop!(g, u, v, props)
   nothing
end




