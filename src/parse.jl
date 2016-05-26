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
function parsegraph(filename::AbstractString, format::Symbol)
   (format == :TGF) && return parsegraph_tgf(filename)
   error("Invalid graph format")
end

################################################# TRIVIAL GRAPH FORMAT #####################################################

""" Parse a text file in the trivial graph format """
function parsegraph_tgf(filename::AbstractString)
   file = open(filename)
   nv, ne = map(x->parse(Int, x), split(readline(file), " "))
   
   data = NDSparse(VertexID[], VertexID[], PropID[], WithDefault(Any[], nothing))
   pmap = PropertyMap()
   ne_i = 1
   adj_buffer = Array{EdgeID}(nv+1)

   while !eof(file)
      line = strip(readline(file), '\n')

      args = split(line, " ")
      (length(args) == 0 || length(line) == 0) && continue

      if length(args) % 2 == 1
         v = parse(Int, args[1])
         for i in eachindex(args)[2:2:end-1]
            prop = args[i]
            val = args[i+1]
            data[v, v, vproptoi(pmap, prop)] = isnumber(val) ? parse(Int, val) : val
         end
      elseif length(args) % 2 == 0
         v1, v2 = map(x->parse(Int, x), args[1:2])
         data[v1, v2, 1] = ne_i
         ne_i += 1

         for i in eachindex(args)[3:2:end-1]
            prop = args[i]
            val = args[i+1]
            data[v1, v2, eproptoi(pmap, prop)] = isnumber(val) ? parse(Int, val) : val
         end
      end
   end
   LocalSparseGraph(nv, ne, data, pmap, adj_buffer)
end