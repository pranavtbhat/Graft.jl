################################################# FILE DESCRIPTION #########################################################

# ParallelGraphs will eventually support several file formats for reading and writing graphs.
# However currently, only a modified version of the Trivial Graph Format is supported. The TGF
# is described below:
# 
# The input file should contain data in the following format:
# <num_vertices> <num_edges>
# <vertex_id> <vertex_prop_1> <val_1> <vertex_prop_2> <val_2> ...
# .
# .
# .
# <from_vertex_id> <to_vertex_id> <edge_property_1> <val_1> <edge_property_2> <val_2> ...
# .
# .
# .
# EOF

################################################# IMPORT/EXPORT ############################################################
export parsegraph


################################################# PARSEGRAPH ###############################################################
""" Parse a text file in a given format """
function parsegraph(filename::AbstractString, format::Symbol, graph_type=LocalSparseGraph)
   (format == :TGF) && return parsegraph_tgf(filename, graph_type)
   error("Invalid graph format")
end

################################################# TRIVIAL GRAPH FORMAT #####################################################

""" Parse a text file in the trivial graph format """
function parsegraph_tgf(filename::AbstractString, graph_type)
   file = open(filename)
   nv, ne = map(x->parse(Int, x), split(readline(file), " "))
   g = emptygraph(graph_type, nv)

   while !eof(file)
      line = strip(readline(file), '\n')
      args = split(line, " ")
      (length(args) == 0 || length(line) == 0) && continue

      if length(args) % 2 == 1
         v = parse(Int, args[1])
         for i in eachindex(args)[2:2:end-1]
            propname = args[i]
            val = args[i+1]
            val = isnumber(val) ? parse(Int, val) : val
            setvprop!(g, v, propname, val)
         end
      elseif length(args) % 2 == 0
         v1, v2 = map(x->parse(Int, x), args[1:2])
         addedge!(g, v1, v2)
         for i in eachindex(args)[3:2:end-1]
            propname = args[i]
            val = args[i+1]
            val = isnumber(val) ? parse(Int, val) : val
            seteprop!(g, v1, v2, propname, val) 
         end
      end
   end
   return g
end