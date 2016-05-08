export Graph, IndexGraph

### 
# GRAPH REPRESENTATIONS
###

abstract Graph

""" Index graph where each vertex can be refered to only """
immutable IndexGraph <: Graph
   nv::VertexID
   ne::EdgeID
   data::NDSparse                                        # Store all the data involved
   vprop_fmap::Dict{ASCIIString, VertexID}               # Vertex Property Forward Map
   vprop_rmap::Dict{VertexID, ASCIIString}               # Vertex Property Reverse Map (Replace with Vector)
   eprop_fmap::Dict{ASCIIString, PropID}                 # Edge Property Forward Map
   eprop_rmap::Dict{PropID, ASCIIString}                 # Edge Property Reverse Map (Replace with Vector)
end


###
# LOOKUPS
###

""" Retrieve vertex properties """
function Base.getindex(g::Graph, v::VertexID)
   vdata = g.data[v, v, :]
   [g.vprop_rmap[t[3]] => vdata[t...] for t in vdata.indexes]
end

""" Retrieve edge properties """
function Base.getindex(g::Graph, v1::VertexID, v2::VertexID)
   edata = g.data[v1, v2, :]
   [g.eprop_rmap[t[3]] => edata[t...] for t in edata.indexes]
end

""" Retrieve the adjacencies of a vertex (including the vertex itself) """
function Base.getindex(g::Graph, v::VertexID, ::Colon)
   adjdata = g.data[v,:,1]
   adjlist = []
   for t in adjdata.indexes
      if t[2] != v
         push!(adjlist, t[2])
      end
   end
   sort!(adjlist)
end
