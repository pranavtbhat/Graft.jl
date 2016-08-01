################################################# FILE DESCRIPTION #########################################################

# This file contains REPL display helpers

################################################# IMPORT/EXPORT ############################################################


################################################# PRINTVAL #################################################################

spaces(i) = join(fill(" ", i))

function printval(io::IO, x)
   s = string(x)
   print(io, sprintval(x, 20))
end

function padding(s::String, len)
   if length(s) > (len - 2)
      string(s[1:(len-5)], "...  ")
   else
      string(s, spaces(len - length(s)))
   end
end

sprintval(x::Number, len) = padding(string(x), len)
sprintval(x::Symbol, len) = padding(string(":", string(x)), len)
sprintval(x::Char, len)   = padding("\'$x\'", len)
sprintval(x::String, len) = padding("\"$x\"", len)
sprintval(x::Void, len)   = padding(string(x), len)

sprintval(e::Pair, len)   = padding(string(e.first,",",e.second), len)
sprintval(g::Graph, len)  = padding("Graph{$(nv(g)) X $(ne(g))}", len)

function sprintval{T,N}(x::AbstractArray{T,N}, len)
   sz = N == 1 ? "[$(length(x))]" : "[$(size(x))]"
   typ = string(T)
   if length(sz) + length(typ) > (len - 2)
      string(typ[1:(len-length(sz)-5)], "...", sz, spaces(2))
   else
      string(typ, sz, spaces(len - length(sz) - length(typ)))
   end
end

sprintval(x::Dict, len) = padding("Dict{$(length(x))}", len)



################################################# DRAW BOX ###############################################################


drawhl(io::IO, len) = print(io, join(fill('\u2500', len)))
drawvl(io::IO) = print(io, "\u2502")

drawljunc(io::IO) = print(io, "\u251c")
drawrjunc(io::IO) = print(io, "\u2524")
drawtjunc(io::IO) = print(io, "\u252c")
drawmjunc(io::IO) = print(io, "\u253c")
drawbjunc(io::IO) = print(io, "\u2534")

drawtlcorner(io::IO) = print(io, "\u250c")
drawtrcorner(io::IO) = print(io, "\u2510")

drawbrcorner(io::IO) = print(io, "\u2518")
drawblcorner(io::IO) = print(io, "\u2514")

drawboxhl(io::IO, len) = drawhl(io, len+2)

function drawbox(io::IO, rows)
   propcols = length(rows[1]) - 1
   n = length(rows)

   # Top
   drawtlcorner(io)
   drawhl(io, 20)
   for i in 1:propcols
      drawtjunc(io)
      drawhl(io, 20)
   end
   drawtrcorner(io)

   for row in rows
      println(io)
      drawvl(io)
      printval(io, row[1])
      for val in row[2:end]
         drawvl(io)
         printval(io, val)
      end
      drawvl(io)

      if row == rows[end]
         continue
      end
      # HLINE
      println(io)
      drawljunc(io)
      drawhl(io, 20)
      for val in row[2:end]
         drawmjunc(io)
         drawhl(io, 20)
      end
      drawrjunc(io)
   end

   println(io)

   # Bottom
   drawblcorner(io)
   drawhl(io, 20)
   for i in 1:propcols
      drawbjunc(io)
      drawhl(io, 20)
   end
   drawbrcorner(io)

   println(io)
end
