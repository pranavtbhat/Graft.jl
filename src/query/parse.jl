################################################# FILE DESCRIPTION #########################################################

# This file contains methods, macros and operators aimed at providing the user a convenient UI over the REPL

################################################# IMPORT/EXPORT ############################################################


################################################# LEAVES ###################################################################

###
# A symbol must be a graph
###
function parsequery(cache::Dict, s::Symbol)
   # Signal that a global variable is in play
   gn = SimpleGraphNode(s)
   push!(cache, gn => nothing)
   return gn
end


################################################# RECURSIVE DESCENT PARSER #################################################

###
# Recursive pipe translation
###
function parsequery(cache::Dict, x::Expr)
   @assert x.head == :call
   @assert x.args[1] == :|>
   pipedparse(cache, parsequery(cache, x.args[2]), x.args[3])
end

###
# Top level dispatch
###
function pipedparse(cache::Dict, piped, x::Expr)
   @assert x.head == :call
   dispatch = x.args[1]

   # Each vertex
   if dispatch == :eachvertex
      return parse_exp(cache, piped, x.args[2])
   end

   # Each edge
   if dispatch == :eachedge
      return parse_exp(cache, piped, x.args[2])
   end

   # Filter
   if dispatch == :filter
      return filter(cache, piped, x.args[2:end]...)
   end

   # Select
   if dispatch == :select
      return select(cache, piped, x.args[2:end]...)
   end

   error("Couldn't parse (sub)expression $x")
end

################################################# DISPATCH ##################################################################

function Base.filter(cache::Dict, graph::GraphNode, fcs::Expr...)
   fc = last(fcs)
   if length(fcs) == 1
      FilterNode(graph, parse_exp(cache, graph, fc))
   else
      rfnode = filter(cache, graph, fcs[1:(end-1)]...)
      FilterNode(rfnode, parse_exp(cache, rfnode, fc))
   end
end

function Base.select(cache::Dict, graph::GraphNode, props::Expr...)
   SelectNode(graph, [parse_property(cache, prop) for prop in props])
end

################################################# PARSING EXPRESSIONS #######################################################

parse_property(x::Expr) = x.args[1]
parse_property(x::QuoteNode) = eval(x)

function parse_property(cache::Dict, x::Expr)
   lhs = x.args[1]
   rhs = x.args[2]

   # Grammar rules:
   lhs == :v && return VertexProperty(parse_property(rhs))

   lhs == :e && return EdgeProperty(parse_property(rhs))

   lhs == :s && return EdgeSourceProperty(parse_property(rhs))

   lhs == :t && return EdgeTargetProperty(parse_property(rhs))

   error("Couldn't parse (sub)expression $x")
end

###
# Literals
###


parse_exp(cache::Dict, graph::GraphNode, x::Number) = LiteralNode(x)
parse_exp(cache::Dict, graph::GraphNode, x::Bool) = LiteralNode(x)
parse_exp(cache::Dict, graph::GraphNode, x::String) = LiteralNode(x)

###
# OPERATIONS
###
const vectorize = Dict(
   :+    =>   .+,
   :-    =>   .-,
   :*    =>   .*,
   :/    =>   ./,
   :(==) =>   .==,
   :!=   =>   .!=,
   :<    =>   .<,
   :<=   =>   .<=,
   :>    =>   .>,
   :>=   =>   .>=,
   :^    =>   .^,
   :in   =>   (item,xs) -> [in(item, x) for x in xs]
)

function parse_exp(cache::Dict, graph::GraphNode, x::Symbol)
   if haskey(vectorize, x)
      vectorize[x]
   elseif isa(eval(x), Function)
      (args...) -> map(eval(x), args...)
   else
      error("Couldn't parse (sub)expression $x")
   end
end

function parse_exp(cache::Dict, graph::GraphNode, x::Expr)
   if x.head == :.
      return TableNode(graph, parse_property(cache, x))
   end

   if x.head == :call || x.head == :comparison
      op  = parse_exp(cache, graph, x.args[1])
      args = map(arg->parse_exp(cache, graph, arg), x.args[2:end])
      return VectorOperation(op, args)
   end

   error("Couldn't parse (sub)expression $x")
end
