################################################# FILE DESCRIPTION #########################################################

# This file contains methods, macros and operators aimed at providing the user a convenient UI over the REPL

################################################# IMPORT/EXPORT ############################################################

export
# Types
parsequery

################################################# LEAVES ###################################################################

###
# Literals
###
parsequery(x::Number) = LiteralNode(x)
parsequery(x::Bool) = LiteralNode(x)
parsequery(x::String) = LiteralNode(x)

###
# Graphs
###
parsequery(g::Graph) = SimpleGraphNode(g)


###
# Symbol
###
parsequery(s::Symbol) = parsequery(eval(s))


################################################# RECURSIVE DESCENT PARSER #################################################

###
# Top level dispatch for functional schematics
###
function parsequery(obj, x::Expr)
   # Grammar rules:
   x.head == :. && return parse_dot(parsequery(obj), x)

   x.head == :call && return parse_call(parsequery(obj), x)

   error("Couldn't parse (sub)expression $x")
end

###
# Top level dispatch for piped schematics
###
function parsequery(x::Expr)
   x.head == :|> && return parse_pipe(x)

   error("Couldn't parse (sub)expression $x")
end

################################################# DOT OPERATOR #############################################################

parseproperty(x::Symbol) = eval(x)
parseproperty(x::QuoteNode) = eval(x)

function parse_dot(gn::GraphNode, x::Expr)
   lhs = x.args[1]
   rhs = x.args[2]

   # Grammar rules:
   lhs == :v && return VertexPropertyNode(gn, parseproperty(rhs))

   lhs == :e && return EdgePropertyNode(gn, parseproperty(rhs))

   error("Couldn't parse (sub)expression $x")
end

################################################# CALL OPERATOR #############################################################

function parse_call(gn::GraphNode, x::Expr)
   f = x.args[1]

   # Grammar rules:
   lhs == :vfilter && return parse_vfilter(gn, x.args[2:end]...)

   error("Couldn't parse (sub)expression $x")
end


################################################# CALL OPERATOR #############################################################

parse_vfilter(gn::GraphNode) = error("Specify atleast one condition for vertex filter")

function parse_vfilter(gn::GraphNode, fcs::Expr...)
   x = last(fcs)
   if length(fcs) == 1
   end
   x = last(fcs)
end
