################################################# FILE DESCRIPTION #########################################################

# The Graph datatype is the core datastructure used in Graft.jl. The Graph datatype has the following fields:
# 1. nv     : The number of vertices in the graph.
# 2. ne     : The number of edges int he graph.
# 3. indxs  : The adjacency matrix for the graph. The SparseMatrixCSC type is used here, both
#             as an adjacency matrix and as an index table, that maps edges onto their entries in the
#             edge dataframe.
# 4. vdata  : A dataframe used to store vertex data. This dataframe is indexed by the internally used
#             vertex identifiers.
# 5. edata  : An edge dataframe used to store edge data. This dataframe is indexed by indxs datastructure.
# 6. lmap   : A label map that maps externally used labels onto the internally used vertex identifiers and vice versa.

################################################# IMPORT/EXPORT ############################################################
export
# Types
Graph,
# Subgraph
subgraph,
# Methods
indxs, vdata, edata, lmap

type Graph
   nv::Int
   ne::Int
   indxs::SparseMatrixCSC{Int,Int}
   vdata::AbstractDataFrame
   edata::AbstractDataFrame
   lmap::LabelMap
end

################################################# GENERATION ################################################################

include("generator.jl")

################################################# ACCESSORS #################################################################

""" The number of vertices in the graph """
nv(g::Graph) = g.nv

""" The number of edges in the graph """
ne(g::Graph) = g.ne

""" Retrieve the adjacency matrix / edge index table """
indxs(g::Graph) = g.indxs

""" Retrieve the vertex dataframe """
vdata(g::Graph) = g.vdata

""" Retrieve the edge dataframe """
edata(g::Graph) = g.edata

""" Retrieve the label map """
lmap(g::Graph)  = g.lmap

#################################################  BASICS ###################################################################

(==)(g1::Graph, g2::Graph) = nv(g1) == nv(g2) && edges(g1) == edges(g2) && lmap(g1) == lmap(g2)

Base.isequal(g1::Graph, g2::Graph) = g1 == g2 && vdata(g1) == vdata(g2) && edata(g1) == edata(g2)

function Base.copy(g::Graph)
   Graph(nv(g), ne(g), copy(indxs(g)), copy(vdata(g)), copy(edata(g)), copy(lmap(g)))
end


function Base.deepcopy(g::Graph)
   Graph(nv(g), ne(g), deepcopy(indxs(g)), deepcopy(vdata(g)), deepcopy(edata(g)), deepcopy(lmap(g)))
end

################################################# COMBINATORIAL ############################################################

include("combinatorial.jl")

################################################# MUTATION #################################################################

include("mutation.jl")

################################################# VDATA ####################################################################

include("vdata.jl")

################################################# VDATA ####################################################################

include("edata.jl")

################################################# LABELLING ################################################################

""" Set labels for all vertices in the graph """
function setlabel!(g::Graph, ls::Vector)
   if length(ls) == nv(g)
      g.lmap = setlabel!(lmap(g), ls)
      return
   else
      error("Trying to assign $(length(ls)) labels to $(nv(g)) vertices")
   end
end

""" Use a vertex property as the vertex label """
function setlabel!(g::Graph, propname::Symbol)
   ls = getvprop(g, :, propname)
   g.lmap = setlabel!(lmap(g), ls)
   return
end

""" Remove all vertex labels """
function setlabel!(g::Graph)
   g.lmap = setlabel!(lmap(g))
   return
end


""" Relabel a single vertex in the graph """
function relabel!(g::Graph, v::VertexID, l)
   g.lmap = relabel!(lmap(g), v, l)
   return
end

""" Relabel a list of vertices in the graph """
function relabel!(g::Graph, vs::VertexList, ls::AbstractVector)
   g.lmap = relabel!(lmap(g), vs, ls)
   return
end


""" Check if the input label is valid """
haslabel(g::Graph, x) = haslabel(lmap(g), x)


""" Translate the input label into the internally used vertex identifier """
decode(g::Graph, x) = decode(lmap(g), x)



""" Translate the input vertex identifier into its externally used label """
encode(g::Graph) = encode(lmap(g))
encode(g::Graph, x) = encode(lmap(g), x)

################################################# DISPLAY ##################################################################

include("display.jl")
