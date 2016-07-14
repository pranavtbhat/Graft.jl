################################################# FILE DESCRIPTION #########################################################

# This file contains the edge descriptor, used for edge queries.

################################################# IMPORT/EXPORT ############################################################

export
# Types
EdgeDescriptor

################################################# INTERNAL IMPLEMENTATION ##################################################
""" Describes a subset of vertices and their properties """
type EdgeDescriptor
   g::Graph
   es::AbstractVector{EdgeID}
   props::Vector
   parent::Union{Void,EdgeDescriptor}
end


# Constructor for Iterator
EdgeDescriptor(g::Graph) = EdgeDescriptor(g, edges(g), listeprops(g), nothing)

# Edge Subset
EdgeDescriptor(x::EdgeDescriptor, ies) = EdgeDescriptor(x.g, edge_subset(x, ies), property_subset(x.props, :), x)

# Property Subset
EdgeDescriptor(x::EdgeDescriptor, ies, props) = EdgeDescriptor(x.g, edge_subset(x, ies), property_subset(x, props), x)

################################################# PROPERTY UNION #############################################################

# Assume same graph for now
(==)(x::EdgeDescriptor, y::EdgeDescriptor) = x.es == y.es && x.props == y.props

# Orphan node in query tree
Base.copy(x::EdgeDescriptor) = EdgeDescriptor(x.g, copy(x.es), copy(x.props), nothing)
Base.deepcopy(x::EdgeDescriptor) = EdgeDescriptor(x.g, deepcopy(x.es), deepcopy(x.props), nothing)

################################################# PROPERTY UNION #############################################################

@inline function property_union!(x::EdgeDescriptor, prop)
   x.props = property_union(x.props, prop)
   nothing
end

@inline property_union(xprop::Vector, prop) = in(prop, xprop) ? xprop : vcat(xprop, prop)

function property_propagate!(x::EdgeDescriptor, propname)
   property_union!(x, propname)
   property_propagate!(x.parent, propname)
end

property_propagate!(x::Void, propname) = nothing

################################################# SHOW ######################################################################

function display_edge_list(io::IO, x::EdgeDescriptor)
   props = sort(x.props)
   es = x.es
   n = length(es)

   println(io, "Edge Descriptor with $n edges and $(length(props)) properties")

   rows = []
   push!(rows, ["Edge Label" map(string, props)...])

   if n <= 10
      for i in 1:min(n,10)
         push!(rows, [encode(x.g, es[i]) [string(geteprop(x.g, es[i], prop)) for prop in props]...])
      end
   else
      for i in 1:min(n,5)
         push!(rows, [encode(x.g, es[i]) [string(geteprop(x.g, es[i], prop)) for prop in props]...])
      end
      push!(rows, ["⋮", ["⋮" for prop in props]...])
      for i in n-5:n
         push!(rows, [encode(x.g, es[i]) [string(geteprop(x.g, es[i], prop)) for prop in props]...])
      end
   end
   drawbox(io, rows)
end

function Base.show(io::IO, x::EdgeDescriptor)
   display_edge_list(io, x)
end


################################################# ITERATION #################################################################

Base.length(x::EdgeDescriptor) = length(x.es)
Base.size(x::EdgeDescriptor) = (length(x),)

Base.start(x::EdgeDescriptor) = start(x.es)
Base.endof(x::EdgeDescriptor) = endof(x.es)

function Base.next(x::EdgeDescriptor, i0)
   e,i = next(x.es, i0)
   (encode(x.g, e), geteprop(x.g, e)), i
end
@inline Base.done(x::EdgeDescriptor, i) = done(x.es, i)


################################################# GETINDEX / SETINDEX #######################################################

# Unit getindex to search for a single label
Base.getindex(x::EdgeDescriptor, e::Pair) = EdgeDescriptor(x, resolve(x.g, e))
Base.getindex(x::EdgeDescriptor, label1, label2) = EdgeDescriptor(x, resolve(x.g, label1=>label2))

# Vector getindex for subset EdgeDescriptors
Base.getindex(x::EdgeDescriptor, is) = EdgeDescriptor(x, is)

# Setindex!
function Base.setindex!(x::EdgeDescriptor, val, propname)
   property_propagate!(x, propname)
   seteprop!(x.g, x.es, val, propname)
end

################################################# MAP #######################################################################

function Base.get(x::EdgeDescriptor, propname)
   if(length(x) == 1)
      geteprop(x.g, first(x.es), propname)
   else
      geteprop(x.g, x.es, propname)
   end
end

################################################# MAP #######################################################################

function Base.map!(f::Function, x::EdgeDescriptor, propname)
   property_propagate!(x, propname)
   seteprop!(x.g, x.es, f, propname)
end

################################################# SELECT ####################################################################

Base.select(x::EdgeDescriptor, props...) = EdgeDescriptor(x, x.es, collect(props))

function Base.select!(x::EdgeDescriptor, props...)
   x.props = property_subset(x, collect(props))
   x
end

################################################# FILTER ####################################################################

function Base.filter(x::EdgeDescriptor, conditions::ASCIIString...)
   es = edge_subset(x, :)
   for condition in conditions
      fn = parse_edge_query(condition)
      es = filter(e->fn(x.g, e...), es)
   end
   EdgeDescriptor(x.g, es, property_subset(x, :), nothing)
end

function Base.filter!(x::EdgeDescriptor, conditions::ASCIIString...)
   for condition in conditions
      fn = parse_edge_query(condition)
      x.es = filter(e->fn(x.g, e...), x.es)
   end
   nothing
end
