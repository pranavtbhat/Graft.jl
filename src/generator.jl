################################################# FILE DESCRIPTION #########################################################

# This file contains methods to generate graphs

################################################# IMPORT/EXPORT ############################################################
export
# Types
emptygraph, randgraph, completegraph, propgraph, samplegraph

################################################# CONSTRUCTION #############################################################

# NV
""" Build an empty graph with nv vertices """
function Graph(nv::Int)
   Graph(nv, 0, spzeros(Int, nv, nv), DataFrame(), DataFrame(), LabelMap(nv))
end

# NV & NE
""" Build a graph with nv vertices and (approximately)ne edges """
function Graph(nv::Int, ne::Int)
   sv = randindxs(nv, ne)
   Graph(nv, nnz(sv), sv, DataFrame(), DataFrame(), IdentityLM(nv))
end

# NV & LS
""" Build an empty graph with nv labelled vertices """
function Graph(nv::Int, ls::AbstractVector)
   if length(ls) == nv
      Graph(nv, 0, spzeros(Int, nv, nv), DataFrame(), DataFrame(), LabelMap(ls))
   else
      error("Trying to assign $(length(ls)) labels to $nv labels")
   end
end

# NV & LS & NE
""" Build a graph with nv labelled vertices and (approximately)ne edges """
function Graph(nv::Int, ls::Vector, ne::Int)
   sv = randindxs(nv, ne)
   Graph(nv, nnz(sv), sv, DataFrame(), DataFrame(), LabelMap(ls))
end

# SparseMatrixCSC
""" Build a graph using the input adjacency matrix """
function Graph(x::SparseMatrixCSC)
   nv = size(x, 1)
   ne = nnz(x)

   sv = copy(x)
   reorder!(sv)

   Graph(nv, ne, sv, DataFrame(), DataFrame(), LabelMap(nv))
end

################################################# EMTPY GRAPH ##############################################################

""" Build an empty graph with nv vertices """
emptygraph(nv::Int) = Graph(nv)

################################################# RANDGRAPH ################################################################

""" Build a graph with nv vertices and (approximately)ne edges """
randgraph(nv::Int, ne::Int) = Graph(nv, ne)

""" Build a graph with nv vertices and a random number of edges """
randgraph(nv::Int) = Graph(nv, rand(1 : (nv * (nv-1))))



###
# TODO: MORE RANDOM GENERATORS
###

################################################# COMPLETE GRAPH ###########################################################

""" Build a complete graph with nv vertices """
function completegraph(nv::Int)
   Graph(completeindxs(nv))
end

################################################# PROPGRAPH ################################################################

""" Returns a small completegraph with properties(for doc examples) """
function propgraph(nv::Int, vprops::Vector{Symbol}, eprops::Vector{Symbol})
   g = completegraph(nv)

   for prop in vprops
      setvprop!(g, :, rand(nv), prop)
   end

   for prop in eprops
      seteprop!(g, :, rand(ne(g)), prop)
   end

   return g
end
################################################# SAMPLE GRAPHS ############################################################

_graph_text = IOBuffer("10\t28\tString\nage\toccupation\nInt\tString\nrelationship\nString\nAbel\t32\tArchitect\nBharath\t35\tBanker\nCamila\t21\tChef\nDalia\t59\tDentist\nEduardo\t24\tEconomist\nFabiola\t37\tFlorist\nGaurav\t46\tGeologist\nHector\t31\tHistorian\nIgnacio\t28\tInterpreter\nJanardan\t59\tJudge\nAbel	Bharath	father\nBharath	Abel	son\nAbel	Camila	friend\nCamila	Abel	friend\nBharath	Camila	familyfriend\nCamila	Bharath	familyfriend\nCamila	Dalia	wife\nDalia	Camila	husband\nDalia	Eduardo	friend\nEduardo	Dalia	friend\nDalia	Fabiola	neighbor\nFabiola	Dalia	neighbor\nDalia	Gaurav	teacher\nGaurav	Dalia	student\nDalia	Hector	father\nHector	Dalia	son\nDalia	Ignacio	daughter\nIgnacio	Dalia	mother\nDalia	Janardan	aunt\nJanardan	Dalia	nephew\nEduardo	Fabiola	friend\nFabiola	Eduardo\tfriend\nFabiola	Gaurav	friend\nGaurav	Fabiola	friend\nHector	Ignacio	granddaughter\nIgnacio	Hector	grandmother\nIgnacio	Janardan	sister\nJanardan	Ignacio	sister")

function samplegraph()
   loadgraph(_graph_text)
end
