################################################# FILE DESCRIPTION #########################################################

# This file contains graph mutation methods

################################################# IMPORT/EXPORT ############################################################

export addvertex!, addedge!, rmvertex!, rmedge!

################################################# ADDVERTEX! ###############################################################

""" Add a vertex to the graph. Returns the internal identifier of the new vertex """
function addvertex!(g::Graph)
   g.nv += 1
   g.indxs = addvertex!(indxs(g))
   addvertex!(g.vdata)
   g.lmap = addvertex!(lmap(g))
   return nv(g)
end

""" Add a labelled vertex to the graph """
function addvertex!(g::Graph, l)
   if !haslabel(g, l)
      g.nv += 1
      g.indxs = addvertex!(indxs(g))
      addvertex!(g.vdata)
      g.lmap = addvertex!(lmap(g), l)
   end
   return decode(g, l)
end

###
# + FOR ADDVERTEX
###
""" Shorthand notation for adding a labelled vertex to the graph """
function (+)(g::Graph, x)
   addvertex!(g, x)
end

""" Shorthand notation for adding multiple lablled vertices """
(+)(g::Graph, xs::AbstractVector) = [g + x for x in xs]

################################################# ADDEDGE! ################################################################

""" Add an edge to the graph. Returns true if successfull """
function addedge!(g::Graph, e::EdgeID)
   if hasedge(g, e)
      return false
   else
      g.ne += 1
      addedge!(indxs(g), e, ne(g))
      addedge!(edata(g))
      return true
   end
end

###
# SETINDEX FOR ADDEDGE
###
""" Shorthand notation for adding an edge between labelled vertices """
function Base.setindex!(g::Graph, y, x)
   addedge!(g, (g + x)=>(g + y))
end

""" Shorthand notation for adding multiple edges between labelled vertices """
function Base.setindex!(g::Graph, ys::Vector, x)
   for y in ys
      addedge!(g, (g + x)=>(g + y))
   end
end


################################################# RMVERTEX! ################################################################

""" Remove a vertex from the graph """
function rmvertex!(g::Graph, v::VertexID)
   if hasvertex(g, v)
      # Decrement vertex count
      g.nv -= 1

      # Reorder entries in the Edge DataFrame
      reorder!(edata(g), indxs(g).nzval)

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

""" Remove a list of vertices from the graph """
function rmvertex!(g::Graph, vs::VertexList)
   if all(hasvertex(g, vs))
      g.nv -= length(vs)

      # Reorder entries in the Edge DataFrame
      reorder!(edata(g), indxs(g).nzval)

      # Remove indexes for edges on v
      g.indxs, erows = rmvertex!(indxs(g), vs)

      # Calculate new edge count
      g.ne = nnz(indxs(g))

      # Remove rows from vertex dataframe
      rmvertex!(vdata(g), vs)

      # Remove rows from edge dataframe
      rmedge!(edata(g), erows)

      # Remove vertex labels
      g.lmap  = rmvertex!(lmap(g), vs)
      return nothing
   else
      error("Invalid vertices: $(filter(x->!hasvertex(g, x), vs))")
   end
end


""" Remove a labelled vertex from the graph """
(-)(g::Graph, x) = rmvertex!(g, decode(g, x))

""" Remove a list of labelled vertices from the graph """
function (-)(g::Graph, xs::Vector)
   rmvertex!(g, decode(g, xs))
end

################################################# RMEDGE! ####################################################################

""" Remove an edge from the graph """
function rmedge!(g::Graph, e::EdgeID)
   if hasedge(g, e)
      g.ne -= 1

      # Remove index for e
      erow = rmedge!(indxs(g), e)

      # Remove row from edge dataframe
      rmedge!(edata(g), erow)

      # Reorder entries in the Edge DataFrame
      reorder!(edata(g), indxs(g).nzval)
      return nothing
   else
      error("Invalid edge $e")
   end
end
