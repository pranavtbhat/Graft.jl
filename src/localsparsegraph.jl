################################################# FILE DESCRIPTION #########################################################

# This file contains subtypes of the LocalSparseGraph type. The graph types contained here use N-Dimensional sparse arrays to 
# store all graph related information. A property map is maintained to store mappings between property keys and indices to 
# the sparse arrays. This type is aimed at being a component of the distributed DistSparseGraph type.

################################################# IMPORT/EXPORT ############################################################

export
# Types
LocalSparseGraph

""" A consolidated Sparse Graph to be used on a single compute node """
type LocalSparseGraph <: Graph
   nv::VertexID                                          # Number of vertexes
   ne::EdgeID                                            # Number of edges
   data::SparseArray                                     # Store all the data involved
   pmap::PropertyMap                                     # Vertex/Edge property map
end


################################################# CONSTRUCTION INTERFACE ###################################################

function emptygraph(::Type{LocalSparseGraph}, num_verices::Int = 0)
   D = NDSparse((MAX_EDGE, MAX_EDGE), Int[], Int[], Int[], WithDefault(Any[], nothing))
   LocalSparseGraph(num_verices, 0, D, PropertyMap())
end

################################################# BASIC GRAPH INTERFACE ####################################################

nv(g::LocalSparseGraph) = g.nv

ne(g::LocalSparseGraph) = g.ne

size(g::LocalSparseGraph) = (nv(g), ne(g))

function adj(g::LocalSparseGraph, v::VertexID)
   # TODO Performance
   flush!(g.data)
   cols = g.data.indexes.columns
   unique(cols[2][searchsorted(cols[1], v)])
end

function addvertex!(g::LocalSparseGraph)
   g.nv += 1
   nothing
end

function addvertex!(g::LocalSparseGraph, props::Dict{PropName,Any})
   g.nv += 1
   setvprop!(g, nv(g), props)
   nothing
end

function addedge!(g::LocalSparseGraph, u::VertexID, v::VertexID)
   g.ne += 1
   seteprop!(g, u, v, 1, 1)
   nothing
end

function addedge!(g::LocalSparseGraph, u::VertexID, v::VertexID, props::Dict{PropName, Any})
   g.ne += 1
   seteprop!(g, u, v, 1, 1)
   seteprop!(g, u, v, props)
   nothing
end

################################################ PROPERTIES INTERFACE #####################################################

listvprops(g::LocalSparseGraph) = vprops(g.pmap)

listeprops(g::LocalSparseGraph) = eprops(g.pmap)

function getvprop(g::LocalSparseGraph, v::VertexID)
   vdata = g.data[v, v, :]
   [itovprop(g.pmap, t[3]) => vdata[t...] for t in vdata.indexes]
end

function getvprop(g::LocalSparseGraph, v::VertexID, propid::PropID)
   g.data[v, v, propid]
end

function getvprop(g::LocalSparseGraph, v::VertexID, propname::PropName)
   g.data[v, v, vproptoi(g.pmap, propname)]
end

function geteprop(g::LocalSparseGraph, u::VertexID, v::VertexID)
   edata = g.data[u, v, :]
   [itoeprop(g.pmap, t[3]) => edata[t...] for t in edata.indexes]
end

function geteprop(g::LocalSparseGraph, u::VertexID, v::VertexID, propid::PropID)
   g.data[u,v,propid]
end

function geteprop(g::LocalSparseGraph, u::VertexID, v::VertexID, propname::PropName)
   g.data[u, v, eproptoi(g.pmap, propname)]
end


function setvprop!(g::LocalSparseGraph, v::VertexID, props::Dict{PropName, Any})
   for (key,val) in props
      setvprop!(g, v, key, val)
   end
end

function setvprop!(g::LocalSparseGraph, v::VertexID, propid::PropID, val::Any)
   setindex!(g.data, val, v, v, propid)
end

function setvprop!(g::LocalSparseGraph, v::VertexID, propname::PropName, val::Any)
   setindex!(g.data, val, v, v, vproptoi(g.pmap, propname))
end

function seteprop!(g::LocalSparseGraph, u::VertexID, v::VertexID, props::Dict{PropName, Any})
   for (key,val) in props
      seteprop!(g, u, v, key, val)
   end
end

function seteprop!(g::LocalSparseGraph, u::VertexID, v::VertexID, propid::PropID, val::Any)
   setindex!(g.data, val, u, v, propid)
end

function seteprop!(g::LocalSparseGraph, u::VertexID, v::VertexID, propname::PropName, val::Any)
   g.data[u, v, 1] == nothing && error("This graph does not contain edge $u -> $v")
   setindex!(g.data, val, u, v, eproptoi(g.pmap, propname))
end


