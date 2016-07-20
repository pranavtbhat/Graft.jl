################################################# FILE DESCRIPTION #########################################################

# This file contains methods, macros and operators for the Graph Datatype

################################################# IMPORT/EXPORT ############################################################

# Make the graph type iterable
Base.start(g::Graph) = 1
Base.done(g::Graph, i) = i == 3

function Base.next(g::Graph, i)
   i == 1 && return VertexDescriptor(g), 2
   i == 2 && return EdgeDescriptor(g), 3
   return nothing, 3
end


################################################# ADJACENCY ################################################################

###
# GETINDEX FOR ADJACENCY
###
function Base.getindex(g::Graph, v)
   encode(g, out_neighbors(g, resolve(g, v)))
end

###
# SETINDEX FOR ADDEDGE
###
function Base.setindex!(g::Graph, y, x)
   addedge!(g, g + x, g + y)
end

function Base.setindex!(g::Graph, ys::Vector, x)
   for y in ys
      addedge!(g, g + x, g + y)
   end
end

################################################# MUTATION ##################################################################
###
# + FOR ADDVERTEX
###
function (+)(g::Graph, x)
   if !haslabel(g, x)
      addvertex!(g)
      setlabel!(g, nv(g), x)
      nv(g)
   else
      resolve(g, x)
   end
end

(+)(g::Graph, xs::Vector) = [g + x for x in xs]


###
# - for RMVERTEX
###
(-)(g::Graph, x) = rmvertex!(g, resolve(g, x))

function (-)(g::Graph, sx::Vector)
   for x in xs
      g - x
   end
end

################################################# SUBGRAPHING ################################################################

Graph(x::VertexDescriptor) = subgraph(x.g, x.vs, x.props)

Graph(x::EdgeDescriptor) = subgraph(x.g, x.es, x.props)

# Pray that they were derived from the same graphs :P
function Graph(V::VertexDescriptor, E::EdgeDescriptor)
   g = V.g
   vlist = V.vs
   elist = E.es
   vproplist = V.props
   eproplist = E.props

   am = subgraph(adjmod(g), vlist, elist)
   pm = subgraph(propmod(g), vlist, elist, vproplist, eproplist)
   lm = subgraph(labelmod(g), vlist)

   Graph(am, pm, lm)
end
