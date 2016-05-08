import NDSparseData: flush!
export Graph, IndexGraph

### 
# GRAPH REPRESENTATIONS
###

abstract Graph
   
""" Graph where each vertex can be refered to only by its index """
immutable IndexGraph <: Graph
   nv::VertexID                                          # Number of vertexes
   ne::EdgeID                                            # Number of edges
   data::NDSparse                                        # Store all the data involved
   pmap::PropertyMap                                     # Vertex/Edge property map
   adj_buffer::Vector{EdgeID}                            # Sort of a colptr (for faster adjacency fetching)
end

###
# FLUSH
###

""" Flush the NDSparseData, and populate the adj_buffer """
function flush!(g::Graph)
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

###
# LOOKUPS
###

""" Retrieve vertex properties as dictionary """
function Base.getindex(g::Graph, v::VertexID)
   flush!(g)
   vdata = g.data[v, v, :]
   [itovprop(g.pmap, t[3]) => vdata[t...] for t in vdata.indexes]
end

""" Retrieve edge properties as dictionary """
function Base.getindex(g::Graph, v1::VertexID, v2::VertexID)
   flush!(g)
   edata = g.data[v1, v2, :]
   [itoeprop(g.pmap, t[3]) => edata[t...] for t in edata.indexes]
end

""" Retrieve the adjacencies of a vertex (including the vertex itself) """
function Base.getindex(g::Graph, v::VertexID, ::Colon)
   flush!(g)
   col = g.data.indexes.columns[2]
   range = g.adj_buffer[v] : g.adj_buffer[v+1] - 1
   unique(col[range])
end
