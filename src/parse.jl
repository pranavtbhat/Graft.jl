################################################# FILE DESCRIPTION #########################################################

# ParallelGraphs will eventually support several file formats for reading and writing graphs.
# However currently, only a type of CSV supported. The format is described below
#
# The input file should contain data in the following format:
# <num_vertices>,<num_edges>
#
# <vertex_label>,<vertex_prop1>,<val_1>,<vertex_prop2>,<val_2> ...
# .
# .
# .
#
# <from_vertex_label>,<to_vertex_label>,<edge_property_1>,<val_1>,<edge_property_2>,<val_2> ...
# .
# .
# .
# EOF

################################################# IMPORT/EXPORT ############################################################
export
# Read Graphs
loadgraph,
# Write Graphs
storegraph


################################################# READ GRAPHS ##############################################################

# Parse token
parseval(x::SubString) = parseval(join(x))
# Prevent infinte loop
function parseval(x::String)
   s = parse(x)
   isa(s, String) ? s : parseval(s)
end
parseval(x::Int) = x
parseval(x::Float64) = x
parseval(x::Char) = x
parseval(x::Symbol) = isdefined(x) ? x : string(x)
parseval(x::Bool) = x
parseval(x::Void) = x
parseval(x) = error("Didn't know what to do with -> $x")

# Parse opening declaration -> <num_vertices> <num_edges>
parse_spec(args::Vector) = (parseval(args[1]), parseval(args[2]))

# Fetch, strip and split the next line from stream
next_line(io::IO) = split(strip(readline(io), '\n'), ",")


# Parse a line describing a vertex -> <vertex_id> <vertex_prop_1> <val_1> <vertex_prop_2> <val_2> ...
function parsevertex(g::Graph, v::VertexID, args::Vector)
   vlabel = parseval(args[1])
   for i in eachindex(args)[2:2:end-1]
      propname = parseval(args[i])
      val = parseval(args[i+1])
      setvprop!(g, v, val, propname)
   end
   vlabel
end

# Parse a line describing an edge ->
function parseedge(g::Graph, args::Vector)
   v1 = resolve(g, parseval(args[1]))
   v2 = resolve(g, parseval(args[2]))
   addedge!(g, v1, v2)

   for i in eachindex(args)[3:2:end-1]
      propname = parseval(args[i])
      val = parseval(args[i+1])
      seteprop!(g, v1, v2, val, propname)
   end
end

function loadgraph(io::IO, graph_type=SparseGraph)
   nv, ne = parse_spec(next_line(io))
   g = emptygraph(graph_type, nv)

   # First blank line
   next_line(io)

   vlabels = [parsevertex(g, v, next_line(io)) for v in 1 : nv]
   setlabel!(g, vlabels)

   # Second blank line
   next_line(io)

   for i in 1 : ne
      parseedge(g, next_line(io))
   end

   g
end

""" Parse a text file in the trivial graph format """
function loadgraph(filename::String, graph_type=SparseGraph)
   file = open(filename)
   g = loadgraph(file, graph_type)
   close(file)
   g
end
################################################# WRITE GRAPHS ##############################################################

# Serialize a value for storage
prepval(x::Int) = string(x)
prepval(x::Float64) = string(x)
prepval(x::Char) = "\'$x\'"
prepval(x::String) = "\"$x\""
prepval(x::Bool) = string(x)
prepval(x::Void) = ""

""" Write a graph to file """
function storegraph(g::Graph, io::IO)
   println(io, "$(nv(g)),$(ne(g))")

   println(io)

   for v in vertices(g)
      print(io, prepval(encode(g, v)))
      for (prop,val) in getvprop(g, v)
         print(io, ",",prepval(prop), ",", prepval(val))
      end
      println(io)
   end

   println(io)

   for e in edges(g)
      v1 = prepval(encode(g, e.first))
      v2 = prepval(encode(g, e.second))
      print(io, v1, ",", v2)
      for (prop,val) in geteprop(g, e)
         print(io, ",", prepval(prop), ",", prepval(val))
      end
      println(io)
   end
end

function storegraph(g::Graph, filename::String)
   file = open(filename, "w")
   storegraph(g, file)
   close(file)
end
