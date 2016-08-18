################################################# FILE DESCRIPTION #########################################################

# This file contains macros aimed at providing the user a convenient UI to the graph datastructures
# over the REPL.

################################################# IMPORT/EXPORT ############################################################

################################################# LEAF NODES ###############################################################

###
# Extract Literal Node
###
exec(cache::Dict, x::LiteralNode) = x.val

###
# Fetch Graph Object
###
exec(cache::Dict, x::SimpleGraphNode) = cache[x]["OBJ"]

###
# Extract Property
###
exec(cache::Dict, x::Property) = x.prop

################################################# VECTOR NODES ##############################################################

###
# Split Table node query
###
exec(cache::Dict, x::TableNode) = exec(cache, x.graph, x.prop)

###
# Fetch vertex property
###
function exec(cache::Dict, x::GraphNode, y::VertexProperty)
   g = exec(cache, x)
   prop = exec(cache, y)

   # Check for special tokens
   if prop == :indegree
      indegree(g)
   elseif prop == :outdegree
      outdegree(g)
   elseif prop == :label
      encode(g)
   else
      getvprop(g, :, prop)
   end
end

###
# Fetch edge property
###
function exec(cache::Dict, x::GraphNode, y::EdgeProperty)
   g = exec(cache, x)
   prop = exec(cache, y)

   if prop == :source
      eit = edges(g)
      encode(g, eit.us)
   elseif prop == :target
      eit = edges(g)
      encode(g, eit.vs)
   else
      geteprop(g, :, prop)
   end
end

###
# Fetch edge source property
###
function exec(cache::Dict, x::GraphNode, y::EdgeSourceProperty)
   g = exec(cache, x)
   prop = exec(cache, y)
   eit = edges(g)

   # Check for special tokens
   if prop == :indegree
      indegree(g, eit.us)
   elseif prop == :outdegree
      outdegree(g, eit.us)
   elseif prop == :label
      encode(g, eit.us)
   else
      getvprop(g, eit.us, prop)
   end
end

###
# Fetch edge target property
###
function exec(cache::Dict, x::GraphNode, y::EdgeTargetProperty)
   g = exec(cache, x)
   prop = exec(cache, y)
   eit = edges(g)

   # Check for special tokens
   if prop == :indegree
      indegree(g, eit.vs)
   elseif prop == :outdegree
      outdegree(g, eit.vs)
   elseif prop == :label
      encode(g, eit.vs)
   else
      getvprop(g, eit.vs, prop)
   end
end

###
# Execute Vector Operation
###
function exec(cache::Dict, x::VectorOperation)
   # Check if given node has already been executed
   if haskey(cache, x)
      return cache[x]
   end

   # Recursively execute arguments
   args = map(arg->exec(cache, arg), x.args)

   # Execute queries
   cache[x] = x.op(args...)
end

###
# Execute Vector Operation
###
exec(cache::Dict, f::Function, x::VectorNode, y::VectorNode) = f(exec(cache, x), exec(cache, y))

################################################# FILTER NODES ###############################################################

###
# Execute filter query
###
function exec(cache::Dict, x::FilterNode)
   # Check if given node has already been executed
   if haskey(cache, x)
      return cache[x]["OBJ"]
   end

   # Recursively execute LHS
   g = exec(cache, x.graph)

   # Recursively execute RHS
   bools = exec(cache, x.bools)

   # Check if this is a vertex filter
   if length(bools) == nv(g)
      # Execute subgraph operation
      sg = subgraph(g, find(bools))

      # Register this FilterNode
      cache[x] = Dict("OBJ"=>sg)

      return sg
   end

   # It must be an edge query then
   if length(bools) == ne(g)
      # Fetch input graph's edges
      eit = edges(g)

      # Execute subgraph operation
      sg = subgraph(g, eit[find(bools)])

      # Register this FilterNode
      cache[x] = Dict("OBJ"=>sg)

      return sg
   end

   # Wait, what?
   error("Incompatible $(bools) for filtering")
end

###
# Execute select query
###
function exec(cache::Dict, x::SelectNode)
   # Check if given node has already been executed
   if haskey(cache, x)
      return cache[x]["OBJ"]
   end

   g = exec(cache, x.graph)

   # Seperate vertex and edge properties
   vprops = filter(x->isa(x, VertexProperty), x.props)
   eprops = filter(x->isa(x, EdgeProperty), x.props)

   # Fetch properties
   vprops = collect(Symbol, map(prop->exec(cache, prop), vprops))
   eprops = collect(Symbol, map(prop->exec(cache, prop), eprops))

   # Execute subgraph operation
   sg = subgraph(subgraph(g, :, :, eprops), :, vprops)

   # Register this SelectNode
   cache[x] = Dict("OBJ"=>sg)

   return sg
end
