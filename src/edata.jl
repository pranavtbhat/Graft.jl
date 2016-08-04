################################################# FILE DESCRIPTION #########################################################

# This file contains the implementation of the Edge DataFrame.

################################################# IMPORT/EXPORT ############################################################

export geteprop, seteprop!

################################################# MUTATION #################################################################

function addedge!(x::AbstractDataFrame)
   push!(x, @data fill(NA, ncols(x)))
   return
end

function rmedge!(x::AbstractDataFrame, erows)
   deleterows!(x, erows)
   return
end

################################################# EPROPS ACCESSORS ##########################################################

listeprops(g::Graph) = names(edata(g))

haseprop(g::Graph, eprop::Symbol) = haskey(edata(g), eprop)

################################################# GETEPROP ##################################################################

"""
Retrieve edge properties. ParallelGraphs presents a sparse storage interface. If an edge doesn't have a property attached,
a default value is returned.

geteprop(g::Graph, e::EdgeID) -> Sub DataFrame containing edge e's properties
"""
geteprop(g::Graph, e::EdgeID) = edata(g)[indxs(g)[e], :]


""" geteprop(g::Graph, es::EdgeList) -> Sub DataFrame containing properties for e in es """
geteprop(g::Graph, es::EdgeList) = edata(g)[indxs(g)[es], :]


""" geteprop(g::Graph, ::Colon) -> Fetch the Edge DataFrame """
geteprop(g::Graph, ::Colon) = edata(g)


""" geteprop(g::Graph, e::EdgeID, eprop::Symbol) -> Fetch the value of a property for edge e """
geteprop(g::Graph, e::EdgeID, eprop::Symbol) = edata(g)[indxs(g)[e], eprop]


""" geteprop(g::Graph, es::EdgeList, eprop::Symbol) -> Fetch the value of a property for edge e in es """
geteprop(g::Graph, es::EdgeList, eprop::Symbol) = edata(g)[indxs(g)[es], eprop]


""" geteprop(g::Graph, ::Colon, eprop::Symbol) -> Fetch the value of a property for all edges """
geteprop(g::Graph, ::Colon, eprop::Symbol) = edata(g)[:,eprop][:]


################################################# SETEPROP ##################################################################

"""
Set edge properties.

seteprop!(g::Graph, e::EdgeID, ps::Pair...) -> Set properties for an edge e
"""
function seteprop!(g::Graph, e::EdgeID, ps::Pair...)
   for (eprop,val) in ps
      seteprop!(g, e, val, eprop)
   end
   return ps
end


""" seteprop!(g::Graph, e::EdgeID, ps::AbstractDataFrame) -> Set all properties for an edge e """
function seteprop!(g::Graph, e::EdgeID, ps::AbstractDataFrame)
   nrow(ps) != 1 && error("Please supply a dataframe with 1 row")
   ncol(ps) != ncol(edata(g)) && error("Please supply a dataframe with $(ncol(edata(g))) columns")

   edata(g)[indxs(g)[e],:] = ps
end


""" seteprop!(g::Graph, es::EdgeList, ps::AbstractDataFrame) -> Set all properties for edge e in es """
function seteprop!(g::Graph, es::EdgeList, ps::AbstractDataFrame)
   nrow(ps) != length(es) && error("Please supply a dataframe with $(length(es)) row")
   ncol(ps) != ncol(edata(g)) && error("Please supply a dataframe with $(ncol(edata(g))) columns")

   edata(g)[indxs(g)[es],:] = ps
end



""" seteprop!(g::Graph, e::EdgeID, val, eprop::Symbol) -> Set a property for an edge e """
function seteprop!(g::Graph, e::EdgeID, val, eprop::Symbol)
   edata(g)[indxs(g)[e], eprop] = val
end


""" seteprop!(g::Graph, es::EdgeList, val(s), eprop::Symbol) -> Set a property for e in es """
function seteprop!(g::Graph, es::EdgeList, val, eprop::Symbol)
   edata(g)[indxs(g)[es], eprop] = val
end


""" seteprop!(g::Graph, ::Colon, val(s), eprop::Symbol) """
function seteprop!(g::Graph, ::Colon, val, eprop::Symbol)
   edata(g)[:, eprop] = val
end

################################################# SUBGRAPH #################################################################

subgraph(x::AbstractDataFrame, es::EdgeList) = edata(g)[indxs(g)[es],:]

subgraph(x::AbstractDataFrame, es::EdgeList, eprops::Vector{Symbol}) = edata(g)[indxs(g)[es], eprops]
