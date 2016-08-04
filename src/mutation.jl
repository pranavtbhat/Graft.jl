################################################# FILE DESCRIPTION #########################################################

# This file contains graph mutation methods

################################################# IMPORT/EXPORT ############################################################

export addvertex!, addedge!, rmvertex!, rmedge!

################################################# ADDVERTEX! ###############################################################

""" Add a vertex to the graph. Returns the label of the new vertex """
function addvertex!(g::Graph)
   g.nv += 1
   g.indxs = addvertex!(indxs(g))
   addvertex!(g.vdata)
   g.lmap = addvertex!(lmap(g))
   return nv(g)
end

function addvertex!(g::Graph, l)
   if !haslabel(g, l)
      g.nv += 1
      g.indxs = addvertex!(indxs(g))
      addvertex!(g.vdata)
      g.lmap = addvertex!(lmap(g))
   end
   return decode(g, l)
end

###
# + FOR ADDVERTEX
###
function (+)(g::Graph, x)
   addvertex!(g, x)
end

(+)(g::Graph, xs::AbstractVector) = [g + x for x in xs]

################################################# ADDEDGE! ################################################################

""" Add an edge to the graph. Returns true if successfull """
function addedge!(g::Graph, e::EdgeID)
   if hasedge(g, e)
      return false
   else
      g.ne += 1
      addedge!(indxs(g), e)
      addedge!(edata(g))
      return true
   end
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


################################################# RMVERTEX! ################################################################

""" Remove a vertex from the graph """
function rmvertex!(g::Graph, v::VertexID)
   if hasvertex(g, v)
      g.nv -= 1
      # Remove indexes for edges on v
      g.indxs, erows = rmvertex!(indxs(g), v)

      # Calculate new edge count
      g.ne = nnz(indxs(g))

      # Remove rows from vertex dataframe
      rmvertex!(vdata(g), v)

      # Remove rows from edge dataframe
      rmedge!(edata(g), erows)

      # Remove vertex labels
      g.lmap  = rmvertex!(lmap(g), v)
      return nothing
   else
      error("Vertex $v doesn't exist")
   end
end

function rmvertex!(g::Graph, vs::VertexList)
   if all(hasvertex(g, vs))
      g.nv -= length(vs)

      # Remove indexes for edge on vs
      g.indxs, erows = rmvertex!(indxs(g), vs)

      # Calculate new edge count
      g.ne = nnz(indxs(g))

      # Remove rows from vertex dataframe
      rmvertex!(vdata(g), v)

      # Remove rows from edge dataframe
      g.edata = rmedge!(edata(g), erows)

      # Remove vertex labels
      g.lmap  = rmvertex!(lmap(g), vs)
      return nothing
   else
      error("Invalid vertices: $(filter(x->!hasvertex(g, x), vs))")
   end
end

###
# - for RMVERTEX
###
(-)(g::Graph, x) = rmvertex!(g, decode(g, x))

function (-)(g::Graph, sx::Vector)
   for x in xs
      g - x
   end
end

################################################# RMEDGE! ####################################################################

function rmedge!(g::Graph, e::EdgeID)
   if hasedge(g, e)
      g.ne -= 1

      # Remove index for e
      erow = rmedge!(indxs(g), e)

      # Remove rows from edge dataframe
      rmedge!(edata(g), erow)
      return nothing
   else
      error("Invalid edge $e")
   end
end
