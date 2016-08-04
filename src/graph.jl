################################################# FILE DESCRIPTION #########################################################

# This file contains the core graph definitions.

################################################# IMPORT/EXPORT ############################################################
export
# Types
Graph,
# Subgraph
subgraph

type Graph
   nv::Int
   ne::Int
   indxs::AbstractArray{Int,2}
   vdata::AbstractDataFrame
   bdata::AbstractDataFrame
   lmap::LabelMap
end

################################################# CONSTRUCTORS #############################################################

# NV
function Graph(nv::Int)
   Graph(nv, 0, spzeros(Int, nv, nv), DataFrame(), DataFrame(), LabelMap(nv))
end

# NV & NE
function Graph(nv::Int, ne::Int)
   sv = randindxs(nv, ne)
   Graph(nv, nnz(sv), sv, DataFrame(), DataFrame(), IdentityLM(nv))
end

# NV & LS
function Graph(nv::Int, ls::Vector)
   if length(ls) == nv
      Graph(nv, 0, spzeros(Int, nv, nv), DataFrame(), DataFrame(), LabelMap(ls))
   else
      error("Trying to assign $(length(ls)) labels to $nv labels")
   end
end

# NV & LS & NE
function Graph(nv::Int, ls::Vector, ne::Int)
   sv = randindxs(nv, ne)
   Graph(nv, nnz(sv), sv, DataFrame(), DataFrame(), LabelMap(ls))
end

# SparseMatrixCSC
function Graph(x::SparseMatrixCSC)
   nv = size(x, 1)
   ne = nnz(x)

   sv = copy(x)
   sv.nzval[:] = 1 : ne

   Graph(nv, ne, sv, DataFrame(), DataFrame(), LabelMap(nv))
end

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

(==)(g1::Graph, g2::Graph) = nv(g1) == nv(g2) && edges(g1) == edges(g2)


function Base.copy(g::Graph)
   Graph(g.nv, g.ne, copy(indxs), copy(x.vdata), copy(x.edata), copy(x.lmap))
end


function Base.deepcopy(g::Graph)
   Graph(g.nv, g.ne, deepcopy(indxs), deepcopy(x.vdata), deepcopy(x.edata), deepcopy(x.lmap))
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
function setlabel!{T}(g::Graph, ls::Vector{T})
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
   setlabel!(lmap(g))
   return
end


###
# RELABEL
###
function relabel!(g::Graph, v::VertexID, l)
   g.lmap = setlabel!(lmap(g), v, l)
   return
end

function relabel!(g::Graph, vs::VertexList, ls::AbstractVector)
   g.lmap = setlabel!(lmap(g), vs, ls)
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
encode(g::Graph, x) = encode(lmap(g), x)

################################################# DISPLAY ##################################################################

function Base.show(io::IO, g::Graph)
   write(io, "Graph with $(nv(g)) vertices and $(ne(g)) edges")
end
