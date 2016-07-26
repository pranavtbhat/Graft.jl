################################################# FILE DESCRIPTION #########################################################

# This file contains macros aimed at providing the user a convenient UI to the graph datastructures
# over the REPL.

################################################# IMPORT/EXPORT ############################################################

export

exec_query

################################################# HELPERS ##################################################################

cant_parse(x::Expr) = error("Couldn't parse (sub)expression $x")

match_getfield(x, s) = false
function match_getfield(x::Expr, s)
   x.head == :. && x.args[1] == s
end

match_setfield(x, s) = false
function match_setfield(x::Expr, s)
   (x.head == :(=) || x.head ==:kw) && match_getfield(x.args[1], s) # KEYWORD ARG CONFLICT!!!
end

match_adj(x, s) = false
function match_adj(x::Expr, s)
   x.head == :ref && x.args[1] == :g && x.args[2] == s
end

fetch_getfield_property(x) = x
fetch_getfield_property(x::QuoteNode) = fetch_getfield_property(eval(x))
fetch_getfield_property(x::Symbol) = isdefined(x) ? x : string(x)

function fetch_getfield_property(x::Expr)
   if x.head == :.
      fetch_getfield_property(x.args[2])
   elseif x.head == :quote
      fetch_getfield_property(x.args[1])
   else
      cant_parse(x)
   end
end


fetch_setfield_property(x::Expr) = fetch_getfield_property(x.args[1])
################################################# RECURSIVE EXECUTION ######################################################

exec_query(x::Number, desc) = fill(x, length(desc))
exec_query(x::Bool, desc) = fill(x, length(desc))
exec_query(x::String, desc) = fill(x, length(desc))
exec_query(x::AbstractArray, desc) = fill(x, length(desc))

# Convert unit operators into
const _sym_map = Dict{Symbol,Symbol}(
   :+ => :.+,
   :- => :.-,
   :*  => :.*,
   :/  => :./,
   :(==) => :.==,
   :!= => :.!=,
   :<  => :.<,
   :<= => :.<=,
   :>  => :.>,
   :>= => :>=,
)

################################################# VERTEX QUERIES ############################################################

function exec_query(x::Symbol, V::VertexDescriptor)
   if haskey(_sym_map, x)
      _sym_map[x]
   elseif x == :v
      encode(V.g, V.vs)
   else
      fill(eval(x), length(V))
   end
end

function exec_query(x::Expr, V::VertexDescriptor)
   # Get field override
   if match_getfield(x, :v)
      return get(V, fetch_getfield_property(x))
   end

   # Set field override
   if match_setfield(x, :v)
      prop = fetch_setfield_property(x)
      vals = exec_query(x.args[2], V)
      set!(V, vals, prop)
      return vals
   end

   # Getindex override for graph
   if match_adj(x, :v)
      return [V.g[v] for v in V]
   end

   # Convert non-adherent query into either :comparison or :call types
   if x.head == :||
      x = Expr(:call, :|, x.args...)
   elseif x.head == :&&
      x = Expr(:call, :&, x.args...)
   end

   # Substitute into adherent query type
   if x.head == :comparison
      # Only substitution required
      map!(y->exec_query(y, V), x.args, x.args)

   elseif x.head == :call
      if haskey(_sym_map, x.args[1])
         # Only substitution required
         map!(y->exec_query(y, V), x.args, x.args)

      else
         # Substition and broadcast required
         fargs = Any[exec_query(y, V) for y in x.args[2:end]]

         if length(fargs) == 0
            # Unary function
            x = Expr(:comprehension, Expr(:call, x.args[1]), Expr(:(=), :i, V.vs))
         else
            x.args = vcat(:map, x.args[1], fargs)
         end
      end
   else
      # We don't understand this query. Try an exec
      try
         return exec_query(eval(x), V)
      catch
         cant_parse(x)
      end
   end

   # Evaluate the processed query
   eval(x)
end

################################################# EDGE QUERIES ##########################################################

function exec_query(x::Symbol, E::EdgeDescriptor)
   if haskey(_sym_map, x)
      _sym_map[x]
   elseif x == :u
      encode(E.g, map(x->x.first, E.es))
   elseif x == :v
      encode(E.g, map(x->x.second, E.es))
   elseif x == :e
      _encode(E.g, E.es)
   elseif isdefined(x)
      fill(eval(x), length(E))
   else
      fill(eval(x), length(E))
   end
end

function exec_query(x::Expr, E::EdgeDescriptor)
   # Get field override u
   if match_getfield(x, :u)
      us = map(x->x.first, E.es)
      return getvprop(E.g, us, fetch_getfield_property(x))
   end

   # Set field override u
   if match_setfield(x, :u)
      us = map(x->x.first, E.es)
      prop = fetch_setfield_property(x)
      vals = exec_query(x.args[2], E)
      setvprop!(E.g, us, vals, prop)
      return vals
   end

   # Get field override v
   if match_getfield(x, :v)
      vs = map(x->x.second, E.es)
      return getvprop(E.g, vs, fetch_getfield_property(x))
   end

   # Set field override v
   if match_setfield(x, :v)
      vs = map(x->x.second, E.es)
      prop = fetch_setfield_property(x)
      vals = exec_query(x.args[2], E)
      setvprop!(E.g, vs, vals, prop)
      return vals
   end

   # Get field override e
   if match_getfield(x, :e)
      return get(E, fetch_getfield_property(x))
   end

   # Set field override e
   if match_setfield(x, :e)
      prop = fetch_setfield_property(x)
      vals = exec_query(x.args[2], E)
      set!(E, vals, prop)
      return vals
   end

   # Getindex override for graph u
   if match_adj(x, :u)
      us = map(x->x.first, E.es)
      return [E.g[u] for u in us]
   end

   # Getindex override for graph v
   if match_adj(x, :v)
      vs = map(x->x.second, E.es)
      return [E.g[v] for v in vs]
   end

   # Convert non-adherent query into either :comparison or :call types
   if x.head == :||
      x = Expr(:call, :|, x.args...)
   elseif x.head == :&&
      x = Expr(:call, :&, x.args...)
   end

   # Substitute into adherent query type
   if x.head == :comparison
      # Only substitution required
      x.args[2:end] = map(y->exec_query(y, E), x.args[2:end])

   elseif x.head == :call
      if haskey(_sym_map, x.args[1])
         # Only substitution required
         map!(y->exec_query(y, E), x.args, x.args)

      else
         # Substition and broadcast required
         fargs = Any[exec_query(y, E) for y in x.args[2:end]]

         if length(fargs) == 0
            # Unary function
            x = Expr(:comprehension, Expr(:call, x.args[1]), Expr(:(=), :i, E.es))
         else
            x.args = vcat(:map, x.args[1], fargs)
         end
      end
   else
      # We don't understand this query. Try an exec
      try
         return exec_query(eval(x), E)
      catch
         cant_parse(x)
      end
   end

   # Evaluate the processed query
   eval(x)
end
