################################################# FILE DESCRIPTION #########################################################

# This file contains methods to generate graphs

################################################# IMPORT/EXPORT ############################################################
export
# Types
emptygraph, randgraph, completegraph

################################################# CONSTRUCTION #############################################################

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
function Graph(nv::Int, ls::AbstractVector)
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
   reorder!(sv)

   Graph(nv, ne, sv, DataFrame(), DataFrame(), LabelMap(nv))
end

################################################# EMTPY GRAPH ##############################################################

emptygraph(nv::Int) = Graph(nv)

################################################# RANDGRAPH ################################################################

randgraph(nv::Int, ne::Int) = Graph(nv, ne)
randgraph(nv::Int) = Graph(nv, rand(1 : (nv * (nv-1))))

""" Returns a small completegraph with properties(for doc examples) """
function randgraph(nv::Int, vprops::Vector{Symbol}, eprops::Vector{Symbol})
   g = completegraph(nv)

   for prop in vprops
      setvprop!(g, :, rand(nv), prop)
   end

   for prop in eprops
      seteprop!(g, :, rand(ne(g)), prop)
   end

   return g
end

###
# TODO: MORE RANDOM GENERATORS
###

################################################# COMPLETE GRAPH ###########################################################

function completegraph(nv::Int)
   Graph(completeindxs(nv))
end
