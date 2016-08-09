################################################# FILE DESCRIPTION #########################################################

# This file contains the implementation of the Edge DataFrame.

################################################# IMPORT/EXPORT ############################################################

export listeprops, haseprop, geteprop, seteprop!

################################################# MUTATION #################################################################

# Use this to reorder the rows Edge DataFrame, so that they align perfectly with the index table.
function reorder!(x::AbstractDataFrame, indxs::Vector{Int})
   for eprop in names(x)
      x[eprop] = x[eprop][indxs]
   end
end

function addedge!(x::AbstractDataFrame)
   if !isempty(x)
      push!(x, @data fill(NA, ncol(x)))
   end
end

function rmedge!(x::AbstractDataFrame, erows)
   if !isempty(x)
      deleterows!(x, erows)
   end
end

################################################# EPROPS ACCESSORS ##########################################################

listeprops(g::Graph) = names(edata(g))

haseprop(g::Graph, eprop::Symbol) = haskey(edata(g), eprop)

################################################# GETEPROP ##################################################################

"""
Retrieve edge properties.

geteprop(g::Graph, e::EdgeID, eprop::Symbol) -> Fetch the value of a property for edge e
"""
geteprop(g::Graph, e::EdgeID, eprop::Symbol) = edata(g)[eprop][indxs(g)[e]]


""" geteprop(g::Graph, es::EdgeList, eprop::Symbol) -> Fetch the value of a property for edge e in es """
geteprop(g::Graph, es::EdgeList, eprop::Symbol) = edata(g)[eprop][indxs(g)[es]]


""" geteprop(g::Graph, ::Colon, eprop::Symbol) -> Fetch the value of a property for all edges """
geteprop(g::Graph, ::Colon, eprop::Symbol) = copy(edata(g)[eprop])


################################################# SETEPROP ##################################################################

"""
Set edge properties.

seteprop!(g::Graph, e::EdgeID, val, eprop::Symbol) -> Set a property for an edge e
"""
function seteprop!(g::Graph, e::EdgeID, val, eprop::Symbol)
   if haseprop(g, eprop)
      edata(g)[indxs(g)[e], eprop] = val
   else
      error("Property $eprop doesn't exist. Please create it on all edges first.")
   end
end


""" seteprop!(g::Graph, es::EdgeList, val(s), eprop::Symbol) -> Set a property for e in es """
function seteprop!(g::Graph, es::EdgeList, val, eprop::Symbol)
   if haseprop(g, eprop)
      edata(g)[eprop][indxs(g)[es]] = val
   else
      error("Property $eprop doesn't exist. Please create it on all edges first.")
   end
end


""" seteprop!(g::Graph, ::Colon, val(s), eprop::Symbol) """
function seteprop!(g::Graph, ::Colon, vals::AbstractVector, eprop::Symbol)
   if length(vals) == ne(g)
      edata(g)[eprop] = vals
   else
      error("Trying to set $(length(vals)) values to $(ne(g)) properties")
   end
end

seteprop!(g::Graph, ::Colon, val, eprop::Symbol) = seteprop!(g, :, fill(val, ne(g)), eprop)

################################################# SUBGRAPH #################################################################

subgraph(x::AbstractDataFrame, es::EdgeList) = edata(g)[indxs(g)[es],:]

subgraph(x::AbstractDataFrame, es::EdgeList, eprops::Vector{Symbol}) = edata(g)[indxs(g)[es], eprops]
