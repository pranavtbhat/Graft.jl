################################################# FILE DESCRIPTION #########################################################

# ParallelGraphs will eventually support several file formats for reading and writing graphs.
# However currently, only a GraphCSV supported. The format is described below
#
# The input file should contain data in the following format:
# <num_vertices>,<num_edges>,<label_type>(1)
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

parseprops(x::SubString) = Symbol(x)
parseprops(props::Vector) = map(parseprops, props)
parseprops(x) = error("Invalid property name $x")

parsetypes(x::SubString) = eval(parse(x))
parsetypes(props::Vector) = map(parsetypes, props)
parsetypes(x) = error("Invalid Property type $x")

# SubString Hack to Char, Bool
Base.Char(x::SubString{String}) = x[1]
Base.Bool(x::SubString{String}) = parse(x)

promote_vector(x::DataType, y::Vector) = collect(x, y)
promote_vector(::Type{Char}, x::Vector) = map(Char, x)
promote_vector(::Type{Bool}, y::Vector) = map(Bool, y)

function printif(cond, s::String)
   if cond
      println(s)
   end
end
################################################# READ GRAPHS ##############################################################

function loadheader(io::IO)
   header_line = split(rstrip(readline(io)), ',')
   vprops_line = split(rstrip(readline(io)), ',')
   vtypes_line = split(rstrip(readline(io)), ',')
   eprops_line = split(rstrip(readline(io)), ',')
   etype_line = split(rstrip(readline(io)), ',')

   Nv = parse(header_line[1])
   Ne = parse(header_line[2])
   ltype = eval(parse(header_line[3]))

   vprops = parseprops(vprops_line)
   vtypes = parsetypes(vtypes_line)

   eprops = parseprops(eprops_line)
   etypes = parsetypes(etype_line)

   return(Nv, Ne, ltype, vprops, vtypes, eprops, etypes)
end


function loadgraph(io::IO, verbose=false)
   printif(verbose, "Fetching Graph Header")
   Nv, Ne, ltype, vprops, vtypes, eprops, etypes = loadheader(io)

   printif(verbose, "Reading File")
   dims = (Nv + Ne, max(1 + length(vprops), 2 + length(eprops)))
   arr = readcsv(io; dims=dims)

   printif(verbose, "Fetching Vertex Labels")
   Lm = LabelMap(promote_vector(ltype, arr[1:Nv, 1]))

   printif(verbose, "Fetching Vertex Data")
   Vdata = DataFrame()
   for (i,prop) in enumerate(vprops)
      vals = promote_vector(vtypes[i], arr[1:Nv,i+1])
      insert!(Vdata, i, vals, Symbol(prop))
   end

   printif(verbose, "Fetching Edges")
   us = decode(Lm, arr[(Nv+1):(Nv+Ne),1])
   vs = decode(Lm, arr[(Nv+1):(Nv+Ne),2])
   Sv = SparseMatrixCSC(Nv, EdgeIter(Ne, us, vs))
   reorder!(Sv)

   printif(verbose, "Fetching Edge Data")
   Edata = DataFrame()
   for (i,prop) in enumerate(eprops)
      vals = promote_vector(etypes[i], arr[(Nv+1):(Nv+Ne),i+2])
      insert!(Edata, i, vals, Symbol(prop))
   end

   printif(verbose, "Constructing Graph")
   Graph(Nv, Ne, Sv, Vdata, Edata, Lm)
end

""" Parse a text file GraphCSV format"""
function loadgraph(filename::String; verbose=false)
   file = open(filename)
   g = loadgraph(file, verbose)
   close(file)
   g
end

################################################# WRITE GRAPHS ##############################################################

""" Write a graph to file """
function storegraph(g::Graph, io::IO)
   Nv,Ne = size(g)

   Ltype = eltype(lmap(g))

   Vprops = listvprops(g)
   Vtypes = eltypes(vdata(g))

   Eprops = listeprops(g)
   Etypes = eltypes(edata(g))


   ls = encode(g)
   Vdata = hcat(ls, [collect(getvprop(g, :, prop)) for prop in Vprops]...)

   eit = edges(g)
   uls = encode(g, eit.us)
   vls = encode(g, eit.vs)

   Edata = hcat(uls, vls, [collect(geteprop(g, :, prop)) for prop in Eprops]...)

   println(io, "$Nv,$Ne,$Ltype")
   println(io, join(Vprops, ','))
   println(io, join(Vtypes, ','))
   println(io, join(Eprops, ','))
   println(io, join(Etypes, ','))

   writedlm(io, Vdata, ',')
   writedlm(io, Edata, ',')
   nothing
end

function storegraph(g::Graph, filename::String)
   file = open(filename, "w")
   storegraph(g, file)
   close(file)
end
