################################################# FILE DESCRIPTION #########################################################

# This file contains the core graph definitions.

################################################# IMPORT/EXPORT ############################################################
export
# Types
Graph,
# Subgraph
subgraph,
# Methods
indxs, vdata, edata

type Graph
   nv::Int
   ne::Int
   indxs::AbstractArray{Int,2}
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

indxs(g::Graph) = g.indxs
vdata(g::Graph) = g.vdata
edata(g::Graph) = g.edata
lmap(g::Graph)  = g.lmap

# Make the graph type iterable
Base.start(g::Graph) = 1
Base.done(g::Graph, i) = i == 3

function Base.next(g::Graph, i)
   i == 1 && return vdata(g), 2
   i == 2 && return edata(g), 3
end

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

###
# SETLABEL
###
function setlabel!(g::Graph, ls::Vector)
   if length(ls) == nv(g)
      g.lmap = setlabel!(lmap(g), ls)
      return
   else
      error("Trying to assign $(length(ls)) labels to $(nv(g)) vertices")
   end
end

function setlabel!(g::Graph, propname::Symbol)
   ls = getvprop(g, :, propname)
   g.lmap = setlabel!(lmap(g), ls)
   return
end

function setlabel!(g::Graph)
   g.lmap = setlabel!(lmap(g))
   return
end


###
# RELABEL
###
function relabel!(g::Graph, v::VertexID, l)
   g.lmap = relabel!(lmap(g), v, l)
   return
end

function relabel!(g::Graph, vs::VertexList, ls::AbstractVector)
   g.lmap = relabel!(lmap(g), vs, ls)
   return
end


###
# HALABEL
###
haslabel(g::Graph, x) = haslabel(lmap(g), x)


###
# DECODE
###
decode(g::Graph, x) = decode(lmap(g), x)



###
# ENCODE
###
encode(g::Graph) = encode(lmap(g))
encode(g::Graph, x) = encode(lmap(g), x)

################################################# DISPLAY ##################################################################

function Base.show(io::IO, g::Graph)
   write(io, "Graph with $(nv(g)) vertices and $(ne(g)) edges")
end
