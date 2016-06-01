################################################# FILE DESCRIPTION #########################################################

# This file contains subtypes of the LocalSparseGraph type. The graph types contained here use N-Dimensional sparse arrays to 
# store all graph related information. A property map is maintained to store mappings between property keys and indices to 
# the sparse arrays. This type is aimed at being a component of the distributed DistSparseGraph type.

################################################# IMPORT/EXPORT ############################################################

export
# Types
LocalSparseGraph

""" A consolidated Sparse Graph to be used on a single compute node """
type LocalSparseGraph <: SparseGraph
   nv::VertexID                                          # Number of vertexes
   ne::EdgeID                                            # Number of edges
   data::SparseArray                                     # Store all the data involved
   pmap::PropertyMap                                     # Vertex/Edge property map
end

################################################# SPARSE GRAPH INTERFACE ###################################################

@inline data(g::LocalSparseGraph) = g.data

@inline pmap(g::LocalSparseGraph) = g.pmap

################################################# CONSTRUCTION INTERFACE ###################################################

function emptygraph(::Type{LocalSparseGraph}, num_verices::Int = 0)
   D = NDSparse((MAX_EDGE, MAX_EDGE), Int[], Int[], Int[], WithDefault(Any[], nothing))
   LocalSparseGraph(num_verices, 0, D, PropertyMap())
end

################################################# BASIC GRAPH INTERFACE ####################################################

nv(g::LocalSparseGraph) = g.nv

ne(g::LocalSparseGraph) = g.ne

Base.size(g::LocalSparseGraph) = (nv(g), ne(g))

function fadj(g::LocalSparseGraph, v::VertexID) # Messy + Poor performance
   flush!(data(g))
   cols = data(g).indexes.columns
   deleteat!(unique(cols[2][searchsorted(cols[1], v)]), 1)
end

function badj(g::LocalSparseGraph, v::VertexID) # Messy + Poor performance
   flush!(data(g))
   cols = data(g).indexes.columns
   unique(cols[1][find(x->x==v, cols[2])])
end

function addvertex!(g::LocalSparseGraph)
   g.nv += 1
   nothing
end

function addvertex!{K<:PropName,V<:Any}(g::LocalSparseGraph, props::Dict{K,V})
   g.nv += 1
   setvprop!(g, nv(g), props)
   nothing
end

function addedge!(g::LocalSparseGraph, u::VertexID, v::VertexID)
   g.ne += 1
   seteprop!(g, u, v, 1, 1)
   nothing
end

function addedge!{K<:PropName,V<:Any}(g::LocalSparseGraph, u::VertexID, v::VertexID, props::Dict{K,V})
   g.ne += 1
   seteprop!(g, u, v, 1, 1)
   seteprop!(g, u, v, props)
   nothing
end