################################################# FILE DESCRIPTION #########################################################

# ParallelGraphs will eventually support several file formats for reading and writing graphs.
# However currently, only a type of CSV supported. The format is described below
#
# The input file should contain data in the following format:
# <num_vertices>,<num_edges> (1)
# <vprop1>,<vprop2>,<vprop3>... (2)
# <vproptype1>,<vproptype2>,<vproptype3>... (3)
# <eprop1>,<eprop2>,<eprop3>... (4)
# <eproptype1>,<eproptype2>,<eproptype3>... (5)
# <vertex_label>,<val_1>,<val_2>,<val_3> ... (6)
# .
# .
# .
# <vertex_label>,<val_1>,<val_2>,<val_3> ... (Nv + 5)
# <from_vertex_label>,<to_vertex_label>,<val_1>,<val_2> ... (Nv + 6)
# .
# .
# .
# <from_vertex_label>,<to_vertex_label>,<val_1>,<val_2> ... (Nv + Ne + 5)
# EOF

################################################# IMPORT/EXPORT ############################################################
export
# Read Graphs
loadgraph,
# Write Graphs
storegraph

################################################# HELPERS ##################################################################




parseprops(x::SubString) = join(x)
parseprops(x) = x
parseprops(props::Vector) = map(parseprops, props)

if CAN_USE_LG
   function hackedges!(x::LightGraphsAM, es::Vector{EdgeID})
      for e in es
         addedge!(x, e...)
      end
   end
end

function hackedges!(x::SparseMatrixAM, es::Vector{EdgeID})
   sort!(es)
   x.ne = length(es)
   x.fdata = init_spmx(nv(x), sort(es), fill(true, length(es)))
   x.bdata = x.fdata'
   nothing
end


# SubString Hack to Char, Bool
Base.Char(x::SubString{String}) = x[1]
Base.Bool(x::SubString{String}) = parse(x)

promote_vector(x::DataType, y::Vector) = collect(x, y)
promote_vector(::Type{Char}, y::Vector) = map(Char, y)
promote_vector(::Type{Bool}, y::Vector) = map(Bool, x)

function printif(cond, s::String)
   if cond
      println(s)
   end
end
################################################# READ GRAPHS ##############################################################

function loadgraph(io::IO, graph_type=SparseGraph, verbose=false)
   arr = readcsv(io; skipblanks=false)

   printif(verbose, "Fetching Graph Header")
   Nv, Ne = collect(Int, arr[1,1:2])

   vprops = parseprops(filter(x -> x != "", arr[2,:]))
   vtypes = map(x->eval(parse(x)), filter(x -> x != "", arr[3,:]))

   eprops = parseprops(filter(x -> x != "", arr[4,:]))
   etypes = map(x->eval(parse(x)), filter(x -> x != "", arr[5,:]))

   g = emptygraph(graph_type, Nv)

   printif(verbose, "Fetching Vertex Labels")
   labels = arr[6:(Nv+5), 1]
   setlabel!(g, labels)

   printif(verbose, "Fetching Vertex Data")
   # vdata = arr[6:(Nv+6), 2:end]
   for (i,prop) in enumerate(vprops)
      vals = promote_vector(vtypes[i], arr[6:(Nv+5),i+1])
      setvprop!(g, :, vals, prop)
   end

   printif(verbose, "Fetching Edges")
   us = resolve(g, arr[(Nv+6):(Nv+5+Ne),1])
   vs = resolve(g, arr[(Nv+6):(Nv+5+Ne),2])
   es = map(EdgeID, us, vs)

   printif(verbose, "Adding Edges")
   # Can be optimized significantly, per Adjmodule type
   hackedges!(adjmod(g), es)

   printif(verbose, "Fetching Edge Data")
   # edata = arr[(Nv+6):(Nv+5+Ne), 3:end]
   for (i,prop) in enumerate(eprops)
      vals = promote_vector(etypes[i], arr[(Nv+6):(Nv+5+Ne),i+2])
      seteprop!(g, :, vals, prop)
   end

   g
end

""" Parse a text file in the trivial graph format """
function loadgraph(filename::String, graph_type=SparseGraph; verbose=false)
   file = open(filename)
   g = loadgraph(file, graph_type, verbose)
   close(file)
   g
end
################################################# WRITE GRAPHS ##############################################################

getvproptype(x::VectorPM, prop) = eltype(vdata(x)[prop])
getvproptype(x::LinearPM, prop) = vprops(x)[prop]

geteproptype(x::VectorPM, prop) = eltype(edata(x)[prop])
geteproptype(x::LinearPM, prop) = eprops(x)[prop]

""" Write a graph to file """
function storegraph(g::Graph, io::IO)
   Nv,Ne = size(g)

   vprops = listvprops(g)
   vtypes = map(x->getvproptype(propmod(g), x), vprops)

   eprops = listeprops(g)
   etypes = map(x->geteproptype(propmod(g), x), eprops)

   labels = encode(g, vertices(g))
   vdata = hcat(labels, [getvprop(g, :, prop) for prop in vprops]...)

   es = collect(edges(g))
   uls = encode(g, map(x->x.first, es))
   vls = encode(g, map(x->x.second, es))

   edata = hcat(uls, vls, [geteprop(g, :, prop) for prop in eprops]...)

   println(io, "$Nv,$Ne")
   println(io, join(vprops, ','))
   println(io, join(vtypes, ','))
   println(io, join(eprops, ','))
   println(io, join(etypes, ','))

   writedlm(io, vdata, ',')
   writedlm(io, edata, ',')
   nothing
end

function storegraph(g::Graph, filename::String)
   file = open(filename, "w")
   storegraph(g, file)
   close(file)
end
