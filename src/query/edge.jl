################################################# FILE DESCRIPTION #########################################################

# This file contains the edge descriptor, used for edge queries.

################################################# IMPORT/EXPORT ############################################################


################################################# INTERNAL IMPLEMENTATION ##################################################

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

function property_union!(x::EdgeDescriptor, prop)
   x.props = property_union(x.props, prop)
   nothing
end

property_union(xprop::Vector, prop) = in(prop, xprop) ? xprop : vcat(xprop, prop)

function property_propagate!(x::EdgeDescriptor, propname)
   property_union!(x, propname)
   property_propagate!(x.parent, propname)
end


################################################# SHOW ######################################################################

function display_edge_list(io::IO, x::EdgeDescriptor)
   es = x.es
   props = sort(map(string, x.props))
   n = length(es)

   println(io, "Edge Descriptor with $n edges and $(length(props)) properties")

   rows = []
   push!(rows, ["Edge Label" map(string, props)...])

   if n <= 10
      for i in 1:min(n,10)
         push!(rows, vcat(encode(x.g, es[i]), Any[geteprop(x.g, es[i], prop) for prop in props]))
      end
   else
      for i in 1:min(n,5)
         push!(rows, vcat(encode(x.g, es[i]), Any[geteprop(x.g, es[i], prop) for prop in props]))
      end
      push!(rows, ["⋮", ["⋮" for prop in props]...])
      for i in n-5:n
         push!(rows, vcat(encode(x.g, es[i]), Any[geteprop(x.g, es[i], prop) for prop in props]))
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
   e, i0 = next(x.es, i0)
   (_encode(x.g, e), i0)
end

Base.done(x::EdgeDescriptor, i) = done(x.es, i)

Base.eachindex(x::EdgeDescriptor) = 1 : length(x)

################################################# GETINDEX ##################################################################

# Unit getindex to search for a single label
Base.getindex(x::EdgeDescriptor, e::Pair) = EdgeDescriptor(x, resolve(x.g, e))
Base.getindex(x::EdgeDescriptor, label1, label2) = EdgeDescriptor(x, resolve(x.g, label1=>label2))

# Vector getindex for subset EdgeDescriptors
Base.getindex(x::EdgeDescriptor, is) = EdgeDescriptor(x, is)

################################################# GET/SET ###################################################################

function Base.get(x::EdgeDescriptor, propname)
   if(length(x) == 1)
      geteprop(x.g, first(x.es), propname)
   else
      geteprop(x.g, x.es, propname)
   end
end

###
# TODO: Don't modify the graph, cache properties in the Descriptor.
###
function set!(x::EdgeDescriptor, val, propname)
   property_propagate!(x, propname)
   seteprop!(x.g, x.es, val, propname) # Bypass validation
end

################################################# MAP ########################################################################

# Function based
Base.map(f::Function, x::EdgeDescriptor) = [f(u,v) for (u,v) in x]

# Query based
Base.map!(f::Function, x::EdgeDescriptor, propname) = set!(x, map(f, x), propname)

################################################# SELECT ####################################################################

Base.select(x::EdgeDescriptor, props...) = EdgeDescriptor(x, x.es, collect(props))

################################################# FILTER ####################################################################

function _filter(farr, E::EdgeDescriptor)
   EdgeDescriptor(E, find(farr))
end
