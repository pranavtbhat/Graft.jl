################################################# FILE DESCRIPTION #########################################################

# This file contains types and methods to display vertex and edge dataframes.

###
# TODO: Avoid reliance on DataFrames internal methods for display. Try to avoid label computation for all vertices
###
################################################# IMPORT/EXPORT ############################################################

export VertexDescriptor, EdgeDescriptor


function Base.show(io::IO, g::Graph)
   write(io, "Graph($(nv(g)) vertices, $(ne(g)) edges, $(listvprops(g)) vertex properties, $(listeprops(g)) edge properties)")
end



################################################# VERTEXDESCRIPTOR ########################################################

immutable VertexDescriptor
   g::Graph
end

function Base.show(io::IO, V::VertexDescriptor)
   g = V.g
   N = nrow(vdata(g))
   if N == 0
      println("No vertex properties to show")
   else
      Vdata = hcat(DataFrame(Labels=encode(g)), vdata(g))
      show(io, Vdata, true, :VertexID, false)
   end
end

function Base.getindex(V::VertexDescriptor, x)
   g = V.g
   v = decode(g, x)
   println("Vertex $x")
   for prop in listvprops(g)
      println("$prop => $(getvprop(g, v, prop))")
   end
end

Base.getindex(V::VertexDescriptor, x::AbstractArray) = error("Vector getindex isn't supported, try a filter instead")

################################################# EDGEDESCRIPTOR ##########################################################

immutable EdgeDescriptor
   g::Graph
end

function Base.show(io::IO, E::EdgeDescriptor)
   g = E.g
   N = nrow(edata(g))

   if N == 0
      println("No edge properties to show")
   else
      eit = edges(g)
      uls = encode(g, eit.us)
      vls = encode(g, eit.vs)
      Edata = hcat(DataFrame(Source=uls, Target=vls), edata(g))
      show(io, Edata, true, :Index, false)
   end
end

function Base.getindex(E::EdgeDescriptor, x, y)
   g = E.g
   e = decode(g, x=>y)
   if hasedge(g, e)
      println("Edge $x => $y")
      for prop in listeprops(g)
         println("$prop => $(geteprop(g, e, prop))")
      end
   else
      error("Invalid edge $x => $y")
   end
end

Base.getindex(E::EdgeDescriptor, x::AbstractArray) = error("Vector getindex isn't supported, try a filter instead")
Base.getindex(E::EdgeDescriptor, x::AbstractArray, y::AbstractArray) = error("Vector getindex isn't supported, try a filter instead")
################################################# SPLICED ASSIGNMENT ######################################################

# Make the graph type iterable
Base.start(g::Graph) = 1
Base.done(g::Graph, i) = i == 3

function Base.next(g::Graph, i)
   i == 1 && return VertexDescriptor(g), 2
   i == 2 && return EdgeDescriptor(g), 3
end
