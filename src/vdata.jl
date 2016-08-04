################################################# FILE DESCRIPTION #########################################################

# This file contains the implementation of the Vertex DataFrame.

################################################# IMPORT/EXPORT ############################################################
export getvprop, setvprop!


################################################# MUTATION #################################################################

function addvertex!(x::AbstractDataFrame)
   push!(x, @data fill(NA, ncols(x)))
   return
end

function rmvertex!(x::AbstractDataFrame, vs)
   deleterows!(x, vs)
   return
end

################################################# PROPERTY ACCESSORS #######################################################

listvprops(g::Graph) = names(vdata(g))

hasvprop(g::Graph, prop::Symbol) = haskey(vdata(g), prop)

################################################# GETVPROP #################################################################

"""
Retrieve vertex properties.

getvprop(g::Graph, v::VertexID) -> Sub DataFrame containing vertex v's properties.
"""
getvprop(g::Graph, v::VertexID) = vdata(g)[v,:]


""" getvprop(g::Graph, vs::VertexList) -> Sub DataFrame containing properties for v in vs """
getvprop(g::Graph, vs::VertexList) = vdata(g)[vs,:]


""" getvprop(g::Graph, ::Colon) -> Fetch the Vertex DataFrame """
getvprop(g::Graph, ::Colon) = vdata(g)


""" getvprop(g::Graph, v::VertexID, vprop::Symbol) -> Fetch the value of a property for vertex v """
getvprop(g::Graph, v::VertexID, vprop::Symbol) = vdata(g)[vprop][v]


""" getvprop(g::Graph, vs::VertexList, vprop::Symbol) -> Fetch the value of a property for v in vs """
getvprop(g::Graph, vs::VertexList, vprop::Symbol) = vdata(g)[vprop][vs]


""" getvprop(g::Graph, ::Colon, vprop::Symbol) -> Fetch the value of a property for all verices """
getvprop(g::Graph, ::Colon, vprop::Symbol) = vdata(g)[vprop][:]

################################################# SETVPROP #################################################################

"""
Set vertex properties.

setvprop!(g::Graph, v::VertexID, ps::Pair...) -> Set properties for for a vertex
"""
function setvprop!(g::Graph, v::VertexID, ps::Pair...)
   for (vprop,val) in ps
      setvprop!(g, v, val, vprop)
   end
   return ps
end


""" setvprop!(g::Graph, v::VertexID, ps::AbstractDataFrame) -> Set all properties for a vertex """
function setvprop!(g::Graph, v::VertexID, ps::AbstractDataFrame)
   nrow(ps) != 1 && error("Please supply a dataframe with 1 row")
   ncol(ps) != ncol(vdata(g)) && error("Please supply a dataframe with $(ncol(vdata(g))) columns")

   vdata(g)[v] = ps
end


""" setvprop!(g::Graph, vs::VertexList, ps::AbstractDataFrame) -> Set all properties for v in vs """
function setvprop!(g::Graph, vs::VertexList, ps::AbstractDataFrame)
   nrow(ps) != length(vs) && error("Please supply a dataframe with $(length(vs)) rows")
   ncol(ps) != ncol(vdata(g)) && error("Please supply a dataframe with $(ncol(vdata(g))) columns")

   vdata(g)[v] = ps
end


""" setvprop!(g::Graph, vs::VertexList, val(s), vprop::Symbol) -> Set a property for v in vs """
function setvprop!(g::Graph, vs::VertexList, val, vprop::Symbol)
   vdata(g)[vprop][vs] = val
end


""" setvprop!(g::Graph, ::Colon, val(s), vprop::Symbol) -> Set a property for v in vertices(g) """
function setvprop!(g::Graph, ::Colon, val, vprop::Symbol)
   vdata(g)[vprop] = val
end

################################################# SUBGRAPHING ##############################################################

subgraph(x::AbstractDataFrame, vs::VertexList) = x[vs,:]

subgraph(x::AbstractDataFrame, vs::VertexList, vprops::Vector{Symbol}) = x[vs,vprops]
