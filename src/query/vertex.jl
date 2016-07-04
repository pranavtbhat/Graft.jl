################################################# FILE DESCRIPTION #########################################################

# This file contains the vertex descriptor, used for vertex queries.

################################################# IMPORT/EXPORT ############################################################

export
# Types
VertexDescriptor

type VertexDescriptor
   g::Graph
   vs
   props
end

function VertexDescriptor(g::Graph)
   VertexDescriptor(g, vertices(g), listvprops(g))
end

################################################# SHOW ######################################################################

function display_vertex_list(io::IO, x::VertexDescriptor)
   rows = []
   push!(rows, ["Vertex Label" map(string, x.props)...])

   n = length(x.vs)
   for v in 1:min(n,5)
      push!(rows, [string(encode(x.g, v)) [string(getvprop(x.g, v, prop)) for prop in x.props]...])
   end
   if n > 20
      push!(rows, ["⋮", ["⋮" for prop in x.props]...])
      for v in (n-5):n
         push!(rows, [string(encode(x.g, v)) [string(getvprop(x.g, v, prop)) for prop in x.props]...])
      end
   end
   drawbox(io, rows)
end

function Base.show(io::IO, x::VertexDescriptor)
   display_vertex_list(io, x)
end


################################################# ITERATION #################################################################

@inline Base.length(x::VertexDescriptor) = length(x.vs)
@inline Base.size(x::VertexDescriptor) = size(x.vs)
@inline Base.start(x::VertexDescriptor) = start(x.vs)
Base.next(x::VertexDescriptor, v) = (encode(x.g, v), getvprop(x.g, v)), next(x.vs, v)
@inline Base.done(x::VertexDescriptor, v) = done(x.vs, v)


################################################# GETINDEX / SETINDEX #######################################################

# Getindex to produce subset Vertex Desciptors
Base.getindex(x::VertexDescriptor, vs) = VertexDescriptor(x.g, x.vs[vs], x.props)
