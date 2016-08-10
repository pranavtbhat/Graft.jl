################################################# FILE DESCRIPTION #########################################################

# This typical subgraphing process is as follows:
# 1. If an edge subset is provided, use the index table to map these edges onto their indices in the edge dataframe.
#
# 2. If a vertex subset is provided, first compute a list of all edges involving these vertices, and the indices of these
#    edges in the edge dataframe. Next compute a subset of the index table involving these vertices, and reorder it.

# 3. If both a vertex subset and an edge subset are provided, compute the edge subgraph first, and then the vertex subset
#    on the edge subgraph.
#
# 4. Use vector indexing to get a sub-dataframe containing rows for the input vertices.
#
# 5. Use vector indexing to get a sub-dataframe containing rows for the input edges, using the indices calculate earlier.
#
# 6. If property subsets are provided, extract the specified columns from the dataframes.

################################################# IMPORT/EXPORT ############################################################
export subgraph

################################################# IMPLEMENTATION ###########################################################

""" Compute the maximal subgraph """
subgraph(g::Graph) = copy(g)

"""
Compute a graph containing only the input vertices and the edges
between them.
"""
function subgraph(g::Graph, vs::VertexList)
   sv,erows = subgraph(indxs(g), vs)
   Graph(length(vs), nnz(sv), sv, subgraph(vdata(g), vs), subgraph(edata(g), erows), subgraph(lmap(g), vs))
end

"""
Compute a graph containing only the input properties in the vertex dataframe.
"""
function subgraph(g::Graph, ::Colon, vprops::Vector{Symbol})
   Graph(nv(g), ne(g), copy(indxs(g)), vdata(g)[vprops], copy(edata(g)), copy(lmap(g)))
end

"""
Compute a graph containing only the input vertices and the edges
between them. Preserve only the input properties in the vertex dataframe.
"""
function subgraph(g::Graph, vs::VertexList, vprops::Vector{Symbol})
   sv,erows = subgraph(indxs(g), vs)
   Graph(length(vs), nnz(sv), sv, subgraph(vdata(g), vs, vprops), subgraph(edata(g), erows), subgraph(lmap(g), vs))
end


""" Compute a graph containing only the input edges. """
function subgraph(g::Graph, es::EdgeList)
   sv,erows = subgraph(indxs(g), es)
   Graph(nv(g), nnz(sv), sv, copy(vdata(g)), subgraph(edata(g), erows), copy(lmap(g)))
end

"""
Compute a graph containing only the input properties in the edge dataframe.
"""
function subgraph(g::Graph, ::Colon, ::Colon, eprops::Vector{Symbol})
   Graph(nv(g), ne(g), copy(indxs(g)), copy(vdata(g)), edata(g)[eprops], copy(lmap(g)))
end

"""
Compute a graph containing only the input edges. Preserve only the input
edge properties in the edge dataframe
"""
function subgraph(g::Graph, es::EdgeList, eprops::Vector{Symbol})
   sv,erows = subgraph(indxs(g), es)
   Graph(nv(g), nnz(sv), sv, copy(vdata(g)), subgraph(edata(g), erows, eprops), copy(lmap(g)))
end


""" Compute a graph containing only the input vertices, and the input edges """
function subgraph(g::Graph, vs::VertexList, es::EdgeList)
   sv,erows = subgraph(indxs(g), vs, es)
   Graph(length(vs), nnz(sv), sv, subgraph(vdata(g), vs), subgraph(edata(g), erows), subgraph(lmap(g), vs))
end


""" Compute a subgraph on all subset properties """
function subgraph(
   g::Graph,
   vs::VertexList,
   es::EdgeList,
   vprops::Vector{Symbol},
   eprops::Vector{Symbol}
   )
   sv,erows = subgraph(indxs(g), vs, es)
   Graph(
      length(vs),
      nnz(sv),
      sv,
      subgraph(vdata(g), vs, vprops),
      subgraph(edata(g), erows, eprops),
      subgraph(lmap(g), vs)
   )
end
