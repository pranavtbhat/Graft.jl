################################################# FILE DESCRIPTION #########################################################

# This file contains methods, macros and operators aimed at providing the user a convenient UI to the graph datastructures
# over the REPL.

################################################# IMPORT/EXPORT ############################################################

export
# Filtering
vertex_filter, edge_filter
################################################# BASICS ###################################################################

# Vertex descriptor and queries
include("query/vertex.jl")

# # Edge descriptor and queries
# include("query/edge.jl")



# ################################################# BASICS ###################################################################
# # Getindex for vertex display
# Base.getindex(g::Graph, ::Colon) = encode(g, vertices(g))
#
# # Getindex for vertex properties
# Base.getindex(g::Graph, label) = getvprop(g, resolve(g, label))
# Base.getindex(g::Graph, ::Colon, propname) = getvprop(g, :, propname)
# Base.getindex(g::Graph, ::Colon, ::Colon) = getvprop(g, :)
#
# # Getindex for edge display
# Base.getindex(g::Graph, ::Type{Pair}) = encode(g, collect(edges(g)))
#
# # Getindex of edge properties
# Base.getindex(g::Graph, e::Pair) = geteprop(g, resolve(g, e))
# Base.getindex(g::Graph, e::Pair, propname) = geteprop(g, resolve(g, e), propname)
# Base.getindex(g::Graph, ::Type{Pair}, propname) = geteprop(g, :, propname)
# Base.getindex(g::Graph, ::Type{Pair}, ::Colon) = geteprop(g, :)
#
# # Getindex for adjacencies
# Base.getindex{T}(g::Graph, e::Pair{T,Colon}) = encode(g, fadj(g, resolve(g, e.first)))
#
# # Setindex for vertex properties
# Base.setindex!(g::Graph, val, label, propname) = setvprop!(g, resolve(g, label), val, propname)
# Base.setindex!(g::Graph, d::Dict, label) = setvprop!(g, resolve(g, label), d)
# Base.setindex!(g::Graph, vals::Vector, ::Colon, propname) = setvprop!(g, :, vals, propname)
# Base.setindex!(g::Graph, dlist::Vector, ::Colon, ::Colon) = setvprop!(g, :, dlist)
#
# # Setindex for edge properties
# Base.setindex!(g::Graph, val, e::Pair, propname) = seteprop!(g, resolve(g, e)..., val, propname)
# Base.setindex!(g::Graph, d::Dict, e::Pair) = seteprop!(g, resolve(g, e), d)
# Base.setindex!(g::Graph, vals::Vector, ::Type{Pair}, propname) = seteprop!(g, :, vals, propname)
# Base.setindex!(g::Graph, dlist::Vector, ::Type{Pair}, ::Colon) = seteprop!(g, :, dlist)
#
# ################################################# FILTERING #################################################################
#
# function Base.filter(g::Graph, vts::ASCIIString...)
#    vlist = vertices(g)
#    elist = collect(edges(g))
#
#    for ts in vts
#       if ismatch(r"v[.](\w+)", ts)
#          # Vertex filter query
#          vlist = vertex_filter(g, ts, vlist)
#       elseif ismatch(r"e[.](\w+)", ts)
#          # Edge filter query
#          elist = edge_filter(g, ts, elist)
#       else
#          error("The input string couldn't be parsed. Please consult documentation")
#       end
#    end
#
#    if(length(elist) == ne(g))
#       return subgraph(g, vlist)
#    elseif(length(vlist) == nv(g))
#       return subgraph(g, elist)
#    else
#       return subgraph(subgraph(g, elist), vlist)
#    end
# end
#
# function vertex_filter(g::Graph, ts::ASCIIString, vlist=vertices(g))
#    fn = parse_vertex_query(ts)
#    filter(v->fn(g, v), vlist)
# end
#
# function edge_filter(g::Graph, ts::ASCIIString, elist=collect(edges(g)))
#    fn = parse_edge_query(ts)
#    filter(e->fn(g, e...), elist)
# end
#
# # VertexFilter Query parsing
# function parse_vertex_query(ts::ASCIIString)
#    ts = strip(ts)
#
#    # Relational filtering on vertex property
#    rvpf = r"^v[.](\w+)\s*(<|>|<=|>=|!=|==)\s*(\w+)$"
#    ismatch(rvpf, ts) && return rvpf_filter(match(rvpf, ts))
#
#    error("The input string couldn't be parsed. Please consult documentation")
# end
#
# function rvpf_filter(m)
#    prop = join(m[1])
#    op = parse(m[2])
#    val = isnumber(m[3]) ? parse(m[3]) : join(m[3])
#
#    return (g,v) -> begin
#       cmp = getvprop(g, v, prop)
#       return cmp == nothing ? false : eval(op)(cmp, val)
#    end
# end
#
#
# # EdgeFilter Query parsing
# function parse_edge_query(ts::ASCIIString)
#    ts = strip(ts)
#    # Relational filtering on edge property
#    repf = r"^e[.](\w+)\s*(<|>|<=|>=|!=|==)\s*(\w+)$"
#    ismatch(repf, ts) && return repf_filter(match(repf, ts))
#
#    error("The input string couldn't be parsed. Please consult documentation")
# end
#
# function repf_filter(m)
#    prop = join(m[1])
#    op = parse(m[2])
#    val = isnumber(m[3]) ? parse(m[3]) : join(m[3])
#
#    return (g, u, v) -> begin
#       cmp = geteprop(g, u, v, prop)
#       return cmp == nothing ? false : eval(op)(cmp, val)
#    end
# end
