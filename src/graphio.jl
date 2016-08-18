################################################# FILE DESCRIPTION #########################################################

# Graft will eventually support several file formats for reading and writing graphs.
# However currently, only a GraphCSV supported. The format is described below
#
# The input file should contain data in the following format:
# <num_vertices>  <num_edges>   <label_type>(1)
# <vprop1>  <vprop2>   <vprop3>... (2)
# <vproptype1>   <vproptype2>   <vproptype3>... (3)
# <eprop1>   <eprop2>   <eprop3>... (4)
# <eproptype1>   <eproptype2>    <eproptype3>... (5)
# <vertex_label>   <val_1>   <val_2>   <val_3> ... (6)
# .
# .
# .
# <vertex_label>   <val_1>   <val_2>   <val_3> ... (Nv + 5)
# <from_vertex_label>   <to_vertex_label>   <val_1>   <val_2> ... (Nv + 6)
# .
# .
# .
# <from_vertex_label>   <to_vertex_label>   <val_1>   <val_2> ... (Nv + Ne + 5)
# EOF

################################################# IMPORT/EXPORT ############################################################
export
# Read Graphs
loadgraph,
# Write Graphs
storegraph

################################################# HELPERS ##################################################################

parseprops(x::SubString) = Symbol(x)
parseprops(props::Vector) = [parseprops(prop) for prop in props]
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
   header_line = split(rstrip(readline(io)), '\t')
   Nv = parse(header_line[1])
   Ne = parse(header_line[2])
   Ltype = eval(parse(header_line[3]))

   vprops_line = rstrip(readline(io))
   Vprops = vprops_line == "" ? Symbol[] : parseprops(split(vprops_line, '\t'))

   vtypes_line = rstrip(readline(io))
   Vtypes = vtypes_line == "" ? DataType[] : parsetypes(split(vtypes_line, '\t'))

   eprops_line = rstrip(readline(io))
   Eprops = eprops_line == "" ? Symbol[] : parseprops(split(eprops_line, '\t'))

   etype_line = rstrip(readline(io))
   Etypes = etype_line == "" ? DataType[] : parsetypes(split(etype_line, '\t'))

   return(Nv, Ne, Ltype, Vprops, Vtypes, Eprops, Etypes)
end

convertarg{T<:Number}(::Type{T}, x::SubString{String}) = parse(T, x)
convertarg(::Type{Any}, x::SubString{String}) = x
convertarg(::Type{Char}, x::SubString{String}) = x[1]

function convertarg(::Type{String}, x::SubString{String})
   if x == ""
      NA
   else
      join(x)
   end
end

convertarg(::DataType, x::SubString{String}) = eval(parse(x))


function readvdata(io::IO, nv::Int, ltype::DataType, vprops::Vector, vtypes::Vector{DataType})
   vdata = Vector{Any}()
   labels = Array{ltype}(nv)

   for vtype in vtypes
      push!(vdata, DataArrays.DataArray(vtype, nv))
   end

   p = Progress(nv, 1)
   for v in 1 : nv
      line = rstrip(readline(io), '\n')
      args = split(line, '\t')
      labels[v] = convertarg(ltype, args[1])

      for i in eachindex(vdata)
         vdata[i][v] = convertarg(vtypes[i], args[1+i])
      end

      update!(p, v)
   end

   DataFrame(vdata, map(Symbol, vprops)), LabelMap(labels)
end

function readedata(io::IO, ne::Int, lmap::LabelMap, eprops::Vector, etypes::Vector{DataType})
   edata = Vector{Any}()

   ltype = eltype(lmap)

   us = Vector{VertexID}(ne)
   vs = Vector{VertexID}(ne)

   for etype in etypes
      push!(edata, DataArrays.DataArray(etype, ne))
   end

   p = Progress(ne, 1)
   for e in 1 : ne
      line = rstrip(readline(io), '\n')
      args = split(line, '\t')

      us[e] = decode(lmap, convertarg(ltype, args[1]))
      vs[e] = decode(lmap, convertarg(ltype, args[2]))

      for i in eachindex(edata)
         edata[i][e] = convertarg(etypes[i], args[2+i])
      end

      update!(p, e)
   end

   DataFrame(edata, map(Symbol, eprops)), EdgeIter(ne, us, vs)
end

function loadgraph(io::IO, verbose=false)
   printif(verbose, "Fetching Graph Header")
   Nv, Ne, ltype, vprops, vtypes, eprops, etypes = loadheader(io)

   printif(verbose, "Loading Vertex Data")
   Vdata, Lm = readvdata(io, Nv::Int, ltype, vprops, vtypes)

   printif(verbose, "Loading Edge Data")
   Edata, eit = readedata(io, Ne, Lm, eprops, etypes)
   Sv = SparseMatrixCSC(Nv, eit)
   reorder!(Sv)

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

   println(io, "$Nv\t$Ne\t$Ltype")
   println(io, join(Vprops, '\t'))
   println(io, join(Vtypes, '\t'))
   println(io, join(Eprops, '\t'))
   println(io, join(Etypes, '\t'))

   writedlm(io, Vdata, '\t')
   writedlm(io, Edata, '\t')
   nothing
end

function storegraph(g::Graph, filename::String)
   file = open(filename, "w")
   storegraph(g, file)
   close(file)
end
