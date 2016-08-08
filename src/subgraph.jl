################################################# FILE DESCRIPTION #########################################################

# This file contains subgraphing methods.

################################################# IMPORT/EXPORT ############################################################
export subgraph

################################################# IMPLEMENTATION ###########################################################

subgraph(g::Graph) = copy(g)

###
# VS
###
function subgraph(g::Graph, vs::VertexList)
   sv,erows = subgraph(indxs(g), vs)
   Graph(length(vs), nnz(sv), sv, subgraph(vdata(g), vs), subgraph(edata(g), erows), subgraph(lmap(g), vs))
end


###
# VS & VPROPS
###
function subgraph(g::Graph, vs::VertexList, vprops::AbstractVector)
   sv,erows = subgraph(indxs(g), vs)
   Graph(length(vs), nnz(sv), sv, subgraph(vdata(g), vs, vprops), subgraph(edata(g), erows), subgraph(lmap(g), vs))
end


###
# ES
###
function subgraph(g::Graph, es::EdgeList)
   sv,erows = subgraph(indxs(g), es)
   Graph(nv(g), nnz(sv), sv, copy(vdata(g)), subgraph(edata(g), erows), copy(lmap(g)))
end


###
# ES & EPROPS
###
function subgraph(g::Graph, es::EdgeList, eprops::AbstractVector)
   sv,erows = subgraph(indxs(g), es)
   Graph(nv(g), nnz(sv), sv, copy(vdata(g)), subgraph(edata(g), erows, eprops), copy(lmap(g)))
end


###
# VS & ES
###
function subgraph(g::Graph, vs::VertexList, es::EdgeList)
   sv,erows = subgraph(indxs(g), vs, es)
   Graph(length(vs), nnz(sv), sv, subgraph(vdata(g), vs), subgraph(edata(g), erows), subgraph(lmap(g), vs))
end


###
# ALL
###
function subgraph(
   g::Graph,
   vs::VertexList,
   es::EdgeList,
   vprops::AbstractVector,
   eprops::AbstractVector
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
