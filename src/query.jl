################################################# FILE DESCRIPTION #########################################################

# This file contains methods, macros and operators aimed at providing the user a convenient UI to the graph datastructures 
# over the REPL.
 
################################################# IMPORT/EXPORT ############################################################

export 
# Filtering
vertex_filter, edge_filter
################################################# BASICS ###################################################################

# Getindex for vertex properties
Base.getindex(g::Graph, v::VertexID) = getvprop(g, v)
Base.getindex(g::Graph, v::VertexID, propname) = getvprop(g, v, propname)

# Getindex of edge properties
Base.getindex(g::Graph, e::Pair{VertexID,VertexID}) = geteprop(g, e...)
Base.getindex(g::Graph, e::Pair{VertexID,VertexID}, propname) = geteprop(g, e..., propname)

# Getindex for adjacencies
Base.getindex(g::Graph, v::VertexID, ::Colon) = fadj(g, v)
Base.getindex(g::Graph, ::Colon, v::VertexID) = badj(g, v)

# Getindex for subgraph
Base.getindex(g::Graph, flist::AbstractVector) = subgraph(g, flist)


# Setindex for vertex properties
Base.setindex!(g::Graph, val, v::VertexID, propname) = setvprop!(g, v, propname, val)

# Setindex for edge properties
Base.setindex!(g::Graph, val, e::Pair{VertexID,VertexID}, propname) = seteprop!(g, e..., propname, val)



################################################# FILTERING #################################################################

function Base.filter(g::Graph, ts::ASCIIString) # TODO: Support for multiple conditions
   if ismatch(r"v[.](\w+)", ts)
      # Vertex filter query
      return subgraph(g, vertex_filter(g, ts))
   elseif ismatch(r"e[.](\w+)", ts)
      # Edge filter query
      return subgraph(g, edge_filter(g, ts))
   end

   error("The input string couldn't be parsed. Please consult documentation")
end

function vertex_filter(g::Graph, ts::ASCIIString)
   fn = parse_vertex_query(ts)
   filter(v->fn(g, v), vertices(g))
end

function edge_filter(g::Graph, ts::ASCIIString)
   fn = parse_edge_query(ts)
   filter(e->fn(g, e...), collect(edges(g)))
end

# VertexFilter Query parsing
function parse_vertex_query(ts::ASCIIString)
   ts = strip(ts)

   # Relational filtering on vertex property
   rvpf = r"^v[.](\w+)\s*(<|>|<=|>=|!=|==)\s*(\w+)$"
   ismatch(rvpf, ts) && return rvpf_filter(match(rvpf, ts))

   error("The input string couldn't be parsed. Please consult documentation")
end

function rvpf_filter(m)
   prop = join(m[1])
   op = parse(m[2])
   val = isnumber(m[3]) ? parse(m[3]) : join(m[3])

   return (g,v) -> begin
      cmp = getvprop(g, v, prop)
      return cmp == nothing ? false : eval(op)(cmp, val)
   end
end


# EdgeFilter Query parsing
function parse_edge_query(ts::ASCIIString)
   ts = strip(ts)
   # Relational filtering on edge property
   repf = r"^e[.](\w+)\s*(<|>|<=|>=|!=|==)\s*(\w+)$"
   ismatch(repf, ts) && return repf_filter(match(repf, ts))

   error("The input string couldn't be parsed. Please consult documentation")
end

function repf_filter(m)
   prop = join(m[1])
   op = parse(m[2])
   val = isnumber(m[3]) ? parse(m[3]) : join(m[3])

   return (g, u, v) -> begin
      cmp = geteprop(g, u, v, prop)
      return cmp == nothing ? false : eval(op)(cmp, val)
   end
end