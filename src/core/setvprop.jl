################################################# FILE DESCRIPTION #########################################################
# This file contains the implementation of setvprop!

################################################# IMPORT/EXPORT ############################################################

export setvprop!

################################################# UNIT SINGLE ##############################################################

"""
Set vertex properties. ParallelGraphs doesn't permit the creating of new properties in strongly typed property modules.

setvprop!(g::Graph, v::VertexID, val, propname) -> Set a value for a vertex
"""
function setvprop!(g::Graph, v::VertexID, val, propname)
   validate_vertex(g, vlist)
   validate_vertex_property(propname)
   setvprop!(propmod(g), v, val, propname)
end


###
# LINEARPM
###
setvprop!(x::LinearPM, v::VertexID, val, propname) = setfield!(vdata(x)[v], propname, val)
setvprop!(x::LinearPM{Any,Any}, v::VertexID, val, propname) = setindex!(vdata(x)[v], val, propname)


###
# 
###
