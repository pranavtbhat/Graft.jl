################################################# FILE DESCRIPTION #########################################################

# This file contains the vertex descriptor, used for vertex queries.

################################################# IMPORT/EXPORT ############################################################


################################################# CONSTRUCTORS #############################################################

# Constructor for Iterator
VertexDescriptor(g::Graph) = VertexDescriptor(g, vertices(g), listvprops(g), nothing)

# Vertex Subset
VertexDescriptor(x::VertexDescriptor, vs) = VertexDescriptor(x.g, vertex_subset(x, vs), property_subset(x.props, :), x)

# Property Subset
VertexDescriptor(x::VertexDescriptor, vs, props) = VertexDescriptor(x.g, copy(x.vs), property_subset(x, props), x)

################################################# MISC #######################################################################

# Assume same graph for now
(==)(x::VertexDescriptor, y::VertexDescriptor) = all(x.vs .== y.vs) && sort(x.props) == sort(y.props)

# Orphan node in query tree
Base.copy(x::VertexDescriptor) = VertexDescriptor(x.g, copy(x.vs), copy(x.props), nothing)
Base.deepcopy(x::VertexDescriptor) = VertexDescriptor(x.g, deepcopy(x.vs), deepcopy(x.props), nothing)


################################################# PROPERTY UNION #############################################################

@inline function property_union!(x::VertexDescriptor, prop)
   x.props = property_union(x, x.props, prop)
   nothing
end

@inline property_union(x::VertexDescriptor, xprop::AbstractVector, prop) = in(prop, xprop) ? xprop : vcat(prop, xprop)

function property_propagate!(x::VertexDescriptor, propname)
   property_union!(x, propname)
   property_propagate!(x.parent, propname)
end

property_propagate!(x::Void, propname) = nothing
################################################# SHOW ######################################################################

function display_vertex_list(io::IO, x::VertexDescriptor)
   vs = x.vs
   props = sort(map(string, x.props))
   n = length(vs)

   println(io, "Vertex Descriptor, with  $n Vertices and $(length(props)) Properties")
   println(io)

   rows = []
   push!(rows, ["Vertex Label" map(string, props)...])

   if n <= 10
      for i in 1:min(n,10)
         push!(rows, vcat(encode(x.g, vs[i]), Any[getvprop(x.g, vs[i], prop) for prop in props]))
      end
   else
      for i in 1:min(n,5)
         push!(rows, vcat(encode(x.g, vs[i]), Any[getvprop(x.g, vs[i], prop) for prop in props]))
      end
      push!(rows, ["⋮", ["⋮" for prop in props]...])
      for i in n-5:n
         push!(rows, vcat(encode(x.g, vs[i]), Any[getvprop(x.g, vs[i], prop) for prop in props]))
      end
   end
   drawbox(io, rows)
end

function Base.show(io::IO, x::VertexDescriptor)
   display_vertex_list(io, x)
end


################################################# ITERATION #################################################################

Base.length(x::VertexDescriptor) = length(x.vs)
Base.size(x::VertexDescriptor) = (length(x),)
Base.eltype(x::VertexDescriptor) = eltype(x.g.labelmod)

Base.start(x::VertexDescriptor) = start(x.vs)
Base.endof(x::VertexDescriptor) = endof(x.vs)

function Base.next(x::VertexDescriptor, i)
   v, i = next(x.vs, i)
   (encode(x.g, v), i)
end

Base.done(x::VertexDescriptor, i) = done(x.vs, i)

Base.eachindex(x::VertexDescriptor) = 1 : length(x )

################################################# GETINDEX ##################################################################

# Unit getindex to search for a single label
Base.getindex(x::VertexDescriptor, label) = VertexDescriptor(x, resolve(x.g, label))

# Vector getindex for subset VertexDescriptors
Base.getindex(x::VertexDescriptor, ls::AbstractVector) = VertexDescriptor(x, resolve(x.g, ls))
Base.getindex(x::VertexDescriptor, ::Colon) = VertexDescriptor(x, :)

################################################# GET and SET! ##############################################################

function Base.get(x::VertexDescriptor, propname)
   property_subset(x, propname)
   length(x) == 1 ? getvprop(x.g, x.vs[1], propname) : getvprop(x.g, x.vs, propname)
end

###
# TODO: Don't modify the graph, cache properties in the Descriptor.
###
function set!(x::VertexDescriptor, val, propname)
   property_propagate!(x, propname)
   setvprop!(x.g, x.vs, val, propname)
end

################################################# MAP ########################################################################

Base.map(f::Function, x::VertexDescriptor) = [f(v) for v in x]

###
# TODO: Don't modify the graph, cache properties in the Descriptor.
###
Base.map!(f::Function, x::VertexDescriptor, propname) = set!(x, map(f, x), propname)

################################################# SELECT ####################################################################

Base.select(x::VertexDescriptor, props...) = VertexDescriptor(x, copy(x.vs), collect(props))

################################################# FILTER ####################################################################

function _filter(farr, V::VertexDescriptor)
   nzind = find(farr)
   VertexDescriptor(V, V.vs[nzind])
end
