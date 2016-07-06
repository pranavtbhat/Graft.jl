################################################# FILE DESCRIPTION #########################################################

# This file contains the vertex descriptor, used for vertex queries.

################################################# IMPORT/EXPORT ############################################################

export
# Types
VertexDescriptor

################################################# INTERNAL IMPLEMENTATION ##################################################
""" Describes a subset of vertices and their properties """
type VertexDescriptor
   g::Graph
   vs
   props
end


# Constructor for Iterator
VertexDescriptor(g::Graph) = VertexDescriptor(g, :, :)

# Vertex Subset
VertexDescriptor(x::VertexDescriptor, v::VertexID) = VertexDescriptor(x.g, vertex_subset(x, v), :)
VertexDescriptor(x::VertexDescriptor, vs::AbstractVector{VertexID}) = VertexDescriptor(x.g, vertex_subset(x, vs), :)
VertexDescriptor(x::VertexDescriptor, ::Colon) = VertexDescriptor(x.g, vertex_subset(x, :), :)

# Property Subset
VertexDescriptor(x::VertexDescriptor, props) = VertexDescriptor(x.g, deepcopy(x.vs), property_subset(x, props))

################################################# PROPERTY UNION #############################################################

@inline function property_union!(x::VertexDescriptor, prop)
   x.props = property_union(x, x.props, prop)
   nothing
end

@inline property_union(x::VertexDescriptor, xprop, prop) = xprop == prop ? prop : vcat(xprop, prop)
@inline property_union(x::VertexDescriptor, xprop::AbstractVector, prop) = in(prop, xprop) ? xprop : vcat(xprop, prop)
@inline property_union(x::VertexDescriptor, xprop::Colon, prop) = vcat(listvprops(x.g), prop)
@inline property_union(x::VertexDescriptor, xprop::Colon, ::Colon) = Colon()

################################################# SHOW ######################################################################

function display_vertex_list(io::IO, x::VertexDescriptor)
   props = x.props == Colon() ? sort(listvprops(x.g)) : sort(x.props)
   vs = x.vs == Colon() ? vertices(x.g) : x.vs

   rows = []
   push!(rows, ["Vertex Label" map(string, props)...])

   n = length(vs)
   if n <= 10
      for i in 1:min(n,10)
         push!(rows, [string(encode(x.g, vs[i])) [string(getvprop(x.g, vs[i], prop)) for prop in props]...])
      end
   else
      for i in 1:min(n,5)
         push!(rows, [string(encode(x.g, vs[i])) [string(getvprop(x.g, vs[i], prop)) for prop in props]...])
      end
      push!(rows, ["⋮", ["⋮" for prop in props]...])
      for i in n-5:n
         push!(rows, [string(encode(x.g, vs[i])) [string(getvprop(x.g, vs[i], prop)) for prop in props]...])
      end
   end
   drawbox(io, rows)
end

function Base.show(io::IO, x::VertexDescriptor)
   display_vertex_list(io, x)
end


################################################# ITERATION #################################################################

Base.length(x::VertexDescriptor) = x.vs == Colon() ? ne(x.g) : length(x.vs)
Base.size(x::VertexDescriptor) = (length(x),)

Base.start(x::VertexDescriptor) = x.vs == Colon() ? 1 : start(x.vs)
Base.next(x::VertexDescriptor, v) = (encode(x.g, v), getvprop(x.g, v)), v+1
Base.done(x::VertexDescriptor, v) = x.vs == Colon() ? v == nv(x.g) : v == last(x.vs)


################################################# GETINDEX / SETINDEX #######################################################

# Unit getindex to search for a single label
Base.getindex(x::VertexDescriptor, label) = VertexDescriptor(x, resolve(x.g, label))

# Vector getindex for subset VertexDescriptors
Base.getindex(x::VertexDescriptor, vs::AbstractVector{VertexID}) = VertexDescriptor(x, vs)
Base.getindex(x::VertexDescriptor, ::Colon) = VertexDescriptor(x, :)

# Setindex!
function Base.setindex!(x::VertexDescriptor, val, propname)
   property_union!(x, propname)
   setvprop!(x.g, x.vs, val, propname)
end

################################################# MAP #######################################################################

function Base.map!(f::Function, x::VertexDescriptor, propname)
   property_union!(x, propname)
   setvprop!(x.g, x.vs, f, propname)
end

################################################# SELECT ####################################################################

Base.select(x::VertexDescriptor, props...) = VertexDescriptor(x, collect(props))

Base.select!(x::VertexDescriptor, props...) = property_union!(x, props)

################################################# FILTER ####################################################################

function Base.filter(x::VertexDescriptor, conditions::ASCIIString...)
   vs = vertex_subset(x, :)
   for condition in conditions
      fn = parse_vertex_query(condition)
      vs = filter(v->fn(x.g, v), vs)
   end
   VertexDescriptor(x, vs)
end

function Base.filter!(x::VertexDescriptor, conditions::ASCIIString...)
   for condition in conditions
      fn = parse_vertex_query(condition)
      x.vs = filter(v->fn(x.g, v), x.vs)
   end
   nothing
end
