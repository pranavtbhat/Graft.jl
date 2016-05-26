################################################# FILE DESCRIPTION #########################################################

# This file contains subtypes of the SparseGraph type. The graph types contained here use N-Dimensional sparse arrays to 
# store all graph related information. A property map is maintained to store mappings between property keys and indices to 
# the sparse arrays.

################################################# IMPORT/EXPORT ############################################################

export
# Types
LocalSparseGraph

################################################# LOCAL SPARSE GRAPH #######################################################

""" A consolidated Sparse Graph to be used on a single compute node """
immutable LocalSparseGraph <: Graph
   nv::VertexID                                          # Number of vertexes
   ne::EdgeID                                            # Number of edges
   data::NDSparse                                        # Store all the data involved
   pmap::PropertyMap                                     # Vertex/Edge property map
   adj_buffer::Vector{EdgeID}                            # Sort of a colptr (for faster adjacency fetching)
end

nv(g::LocalSparseGraph) = g.nv
ne(g::LocalSparseGraph) = g.ne

function adj(g::LocalSparseGraph, v::VertexID) # SUPER MESSY
   flush!(g)
   col = g.data.indexes.columns[2]
   range = g.adj_buffer[v] : g.adj_buffer[v+1] - 1
   unique(col[range])
end

function getprop(g::LocalSparseGraph, v::VertexID)
   flush!(g)
   vdata = g.data[v, v, :]
   [itovprop(g.pmap, t[3]) => vdata[t...] for t in vdata.indexes]
end

function getprop(g::LocalSparseGraph, v::VertexID, propname::AbstractString)
   g.data[v, v, vproptoi(g.pmap, propname)]
end

function getprop(g::LocalSparseGraph, u::VertexID, v::VertexID)
   flush!(g)
   edata = g.data[u, v, :]
   [itoeprop(g.pmap, t[3]) => edata[t...] for t in edata.indexes]
end

function getprop(g::LocalSparseGraph, u::VertexID, v::VertexID, propname::AbstractString)
   g.data[u, v, eproptoi(g.pmap, propname)]
end

function setprop!(g::LocalSparseGraph, v::VertexID, propname::AbstractString, val::Any)
   setindex!(g.data, val, v, v, vproptoi(g.pmap, propname))
end

function setprop!(g::LocalSparseGraph, u::VertexID, v::VertexID, propname::AbstractString, val::Any)
   setindex!(g.data, val, u, v, eproptoi(g.pmap, propname))
end

""" Flush the NDSparseData, and populate the adj_buffer """
function flush!(g::LocalSparseGraph) # SUPER MESSY
   if !isempty(g.data.data_buffer)
      flush!(g.data)
      buf = g.adj_buffer
      col = g.data.indexes.columns[1]

      g.adj_buffer[1] = 1
      cur_v = 1
      i = 1
      for i = eachindex(col)
         if cur_v != col[i]
            cur_v += 1
            g.adj_buffer[cur_v] = i
         end
      end
      g.adj_buffer[cur_v+1] = i + 1 
   end

   nothing
end