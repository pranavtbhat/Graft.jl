################################################# FILE DESCRIPTION #########################################################

# This file contains macros aimed at providing the user a convenient UI to the graph datastructures
# over the REPL.

################################################# IMPORT/EXPORT ############################################################

export

exec_query

################################################# HELPERS ##################################################################

cant_parse(x::Expr) = error("Couldn't parse (sub)expression $x")

is_vertex_getfield(x) = false
function is_vertex_getfield(x::Expr)
   x.head == :. && x.args[1] == :v
end

is_vertex_setfield(x) = false
function is_vertex_setfield(x::Expr)
   x.head == :(=) && is_vertex_getfield(x.args[1])
end


fetch_getfield_property(x) = x
fetch_getfield_property(x::Expr) = fetch_getfield_property(x.args[2])
fetch_getfield_property(x::QuoteNode) = fetch_getfield_property(eval(x))
fetch_getfield_property(x::Symbol) = isdefined(x) ? x : string(x)

fetch_setfield_property(x::Expr) = fetch_getfield_property(x.args[1])
################################################# RECURSIVE EXECUTION ######################################################

exec_query(x::Number, desc) = fill(x, length(desc))
exec_query(x::Bool, desc) = fill(x, length(desc))
exec_query(x::AbstractString, desc) = fill(x, length(desc))
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

function exec_query(x::Symbol, desc)
   if haskey(_sym_map, x)
      _sym_map[x]
   elseif isdefined(x)
      fill(eval(x), length(V))
   end
end

function exec_query(x::Expr, V::VertexDescriptor)

   # Get field override
   if is_vertex_getfield(x)
      return get(V, fetch_getfield_property(x))
   end

   # Set field override
   if is_vertex_setfield(x)
      prop = fetch_setfield_property(x)
      return set!(V, exec_query(x.args[2], V), prop)
   end

   # Convert non-adherent query into either :comparison or :call types
   if x.head == :||
      x.head = :comparison
      x.args = vcat(:|, args...)
   elseif x.head == :&&
      x.head == comparison
      x.args = vcat(:&, args...)
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
