################################################# FILE DESCRIPTION #########################################################

# This file contains subtypes of the LocalSparseGraph type. The graph types contained here use N-Dimensional sparse arrays to 
# store all graph related information. A property map is maintained to store mappings between property keys and indices to 
# the sparse arrays. This type is aimed at being a component of the distributed DistSparseGraph type.

################################################# IMPORT/EXPORT ############################################################

export
# Types
LocalSparseGraph

""" A consolidated Sparse Graph to be used on a single compute node """
immutable LocalSparseGraph <: Graph
   nv::VertexID                                          # Number of vertexes
   ne::EdgeID                                            # Number of edges
   data::SparseArray                                     # Store all the data involved
   pmap::PropertyMap                                     # Vertex/Edge property map
end


################################################# CONSTRUCTION INTERFACE ###################################################

function emptygraph(::Type{LocalSparseGraph})
   D = NDSparse((MAX_EDGE, MAX_EDGE), Int[], Int[], Int[], WithDefault(Any[], nothing))
   LocalSparseGraph(0, 0, D, PropertyMap())
end

################################################# BASIC GRAPH INTERFACE ####################################################

nv(g::LocalSparseGraph) = g.nv

ne(g::LocalSparseGraph) = g.ne

size(g::LocalSparseGraph) = (nv(g), ne(g))

function adj(g::LocalSparseGraph, v::VertexID)
   !(v in 1 : nv(g)) && error("This graph does not contain vertex $v") 
   flush!(g.data)
   cols = g.data.indexes.columns
   unique(cols[2][searchsorted(cols[1], v)])
end

function addvertex(g::LocalSparseGraph, props::Pair...)
   D = g.data
   for (key,val) in props
      setindex!(D, val, v, v, vproptoi(g.pmap, propname))
   end
   LocalSparseGraph(nv(g)+1, ne(g), D, g.pmap)
end

function addedge(g::LocalSparseGraph, u::VertexID, v::VertexID, props::Pair...)
   !(u in 1 : nv(g)) && error("This graph does not contain vertex $u")
   !(v in 1 : nv(g)) && error("This graph does not contain vertex $v")

   D = g.data
   setindex!(D, ne(g)+1, u, v, 1)
   for(key,val) in props
      setindex!(D, val, u, v, eproptoi(g.pmap, propname))
   end
   LocalSparseGraph(nv(g), ne(g)+1, D, g.pmap)
end

################################################# PROPERTIES INTERFACE #####################################################

listvprops(g::LocalSparseGraph) = vprops(g.pmap)

listeprops(g::LocalSparseGraph) = eprops(g.pmap)

function getprop(g::LocalSparseGraph, v::VertexID)
   !(v in 1 : nv(g)) && error("This graph does not contain vertex $v")
   vdata = g.data[v, v, :]
   [itovprop(g.pmap, t[3]) => vdata[t...] for t in vdata.indexes]
end

function getprop(g::LocalSparseGraph, v::VertexID, propname::PropName)
   !(v in 1 : nv(g)) && error("This graph does not contain vertex $v")
   g.data[v, v, vproptoi(g.pmap, propname)]
end

function getprop(g::LocalSparseGraph, u::VertexID, v::VertexID)
   g.data[u, v, 1] == nothing && error("This graph does not contain edge $u -> $v")
   edata = g.data[u, v, :]
   [itoeprop(g.pmap, t[3]) => edata[t...] for t in edata.indexes]
end

function getprop(g::LocalSparseGraph, u::VertexID, v::VertexID, propname::PropName)
   g.data[u, v, 1] == nothing && error("This graph does not contain edge $u -> $v")
   g.data[u, v, eproptoi(g.pmap, propname)]
end

function setprop!(g::LocalSparseGraph, v::VertexID, propname::PropName, val::Any)
   !(v in 1 : nv(g)) && error("This graph does not contain vertex $v")
   setindex!(g.data, val, v, v, vproptoi(g.pmap, propname))
end

function setprop!(g::LocalSparseGraph, u::VertexID, v::VertexID, propname::PropName, val::Any)
   g.data[u, v, 1] == nothing && error("This graph does not contain edge $u -> $v")
   setindex!(g.data, val, u, v, eproptoi(g.pmap, propname))
end


