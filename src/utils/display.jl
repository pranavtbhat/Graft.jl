################################################# FILE DESCRIPTION #########################################################

# This file contains REPL display helpers

################################################# IMPORT/EXPORT ############################################################


################################################# BOX PRINTING #############################################################

function printval(io::IO, x)
   s = string(x)
   if length(s) > 15
      @printf io "%-15s...  " join(s[1:15])
   else
      @printf io "%-20s" s
   end
end

function printval(io::IO, e::Pair)
   s1 = string(e.first)
   s2 = string(e.second)
   @printf io "%-20s" "$(s1[1:min(8,length(s1))]),$(s2[1:min(8,length(s2))])"
end

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
