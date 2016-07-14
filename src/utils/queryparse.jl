################################################# FILE DESCRIPTION ############################################################

# This file contains methods to parse query strings

################################################# IMPORT/EXPORT ###############################################################

export parse_vertex_query, parse_edge_query

################################################# FILTER SUBSTITUTION #########################################################

rcvf(op::Function, y::Function, x) = (g,v) -> op(x, y(g,v))
rcvf(op::Function, y, x) = (g,v) -> op(x, y)

cvf(op::Function, x::Function, y::Function) = (g,v) -> op(x(g,v), y(g,v))
cvf(op::Function, x::Function, y) = (g,v) -> op(x(g,v), y)
cvf(op::Function, x, y) = rcvf(op, y, x)


rcvf(op::Symbol, y::Function, x) = (g,v) -> eval(Expr(op, x, y(g,v)))
rcvf(op::Symbol, y, x) = (g,v) -> eval(Expr(op, x, y))

cvf(op::Symbol, x::Function, y::Function) = (g,v) -> eval(Expr(op, x(g,v), y(g,v)))
cvf(op::Symbol, x::Function, y) = (g,v) -> eval(Expr(op, x(g,v), y))
cvf(op::Symbol, x, y) = rcvf(op, y, x)

parse_vertex_query(x::Int) = x
parse_vertex_query(x::Float64) = x
parse_vertex_query(x::AbstractString) = x
parse_vertex_query(x::Char) = x
parse_vertex_query(x) = string(x)


function parse_vertex_query(x::Expr)
   if x.head == :.
      word = eval(x.args[2])

      if isa(word, Symbol) && !isdefined(word)
         word = string(word)
      end
      return (g,v) -> getvprop(g, v, word)
   end

   if x.head == :comparison
      op = eval(x.args[2])
      lhs = parse_vertex_query(x.args[1])
      rhs = parse_vertex_query(x.args[3])
      return cvf(op, lhs, rhs)
   end

   if x.head in [:call, :|, :&]
      op = eval((x.args[1]))
      a1 = parse_vertex_query(x.args[2])
      a2 = parse_vertex_query(x.args[3])
      return cvf(op, a1, a2)
   end

   if x.head in [:||, :&&]
      op = x.head
      a1 = parse_vertex_query(x.args[1])
      a2 = parse_vertex_query(x.args[2])
      return cvf(op, a1, a2)
   end
   error("Couldn't parse (sub)expression $x")
end

function parse_vertex_query(s::ASCIIString)
   parse_vertex_query(parse(s))
end

################################################# EDGE QUERY ##################################################################

rcef(op::Function, y::Function, x) = (g,u,v) -> op(x, y(g,u,v))
rcef(op::Function, y, x) = (g,u,v) -> op(x, y)

cef(op::Function, x::Function, y::Function) = (g,u,v) -> op(x(g,u,v), y(g,u,v))
cef(op::Function, x::Function, y) = (g,u,v) -> op(x(g,u,v), y)
cef(op::Function, x, y) = rcef(op, y, x)


rcef(op::Symbol, y::Function, x) = (g,u,v) -> eval(Expr(op, x, y(g,u,v)))
rcef(op::Symbol, y, x) = (g,u,v) -> eval(Expr(op, x, y))

cef(op::Symbol, x::Function, y::Function) = (g,u,v) -> eval(Expr(op, x(g,u,v), y(g,u,v)))
cef(op::Symbol, x::Function, y) = (g,u,v) -> eval(Expr(op, x(g,u,v), y))
cef(op::Symbol, x, y) = rcef(op, y, x)

parse_edge_query(x::Int) = x
parse_edge_query(x::Float64) = x
parse_edge_query(x::AbstractString) = x
parse_edge_query(x::Char) = x
parse_edge_query(x) = string(x)

function parse_edge_query(x::Expr)
   if x.head == :.
      word = eval(x.args[2])

      if isa(word, Symbol) && !isdefined(word)
         word = string(word)
      end
      return (g,u,v) -> geteprop(g, u, v, word)
   end

   if x.head == :comparison
      op = eval(x.args[2])
      lhs = parse_edge_query(x.args[1])
      rhs = parse_edge_query(x.args[3])
      return cef(op, lhs, rhs)
   end

   if x.head in [:call, :|, :&]
      op = eval((x.args[1]))
      a1 = parse_edge_query(x.args[2])
      a2 = parse_edge_query(x.args[3])
      return cef(op, a1, a2)
   end

   if x.head in [:||, :&&]
      op = x.head
      a1 = parse_edge_query(x.args[1])
      a2 = parse_edge_query(x.args[2])
      return cef(op, a1, a2)
   end
   error("Couldn't parse (sub)expression $x")
end

function parse_edge_query(s::ASCIIString)
   parse_edge_query(parse(s))
end
