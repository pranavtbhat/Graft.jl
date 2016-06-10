################################################# FILE DESCRIPTION #########################################################

# This file contains methods, macros and operators aimed at providing the user a convenient UI to the graph datastructures 
# over the REPL.
 
################################################# IMPORT/EXPORT ############################################################

export 
# Filtering
parse_filter_query, vertex_filter
################################################# BASICS ###################################################################

# Getindex
Base.getindex(g::Graph, v::VertexID) = getvprop(g, v)
Base.getindex(g::Graph, u::VertexID, v::VertexID) = geteprop(g, u, v)
Base.getindex(g::Graph, v::VertexID, ::Colon) = fadj(g, v)
Base.getindex(g::Graph, ::Colon, v::VertexID) = badj(g, v)

# Setindex

Base.setindex!(g::Graph, val, v, propname) = setvprop!(g, v, propname, val)
Base.setindex!(g::Graph, val, u, v, propname) = seteprop!(g, u, v, propname, val)

################################################# FILTERING #################################################################

function Base.filter(g::Graph, ts::ASCIIString)
   fn = parse_filter_query(ts)
   vlist = filter(v->fn(g, v), 1 : nv(g))
   subgraph(g, vlist)
end

function parse_filter_query(ts::ASCIIString)
   ts = strip(ts)
   rvpf = r"v[.](\w+)\s*(<|>|<=|>=|!=|==)\s*(\w+)"
   
   if ismatch(rvpf, ts)
      m = match(rvpf, ts)
      prop = join(m[1])
      op = parse(m[2])
      val = parse(m[3])
      return (g,v) -> begin
         cmp = getvprop(g, v, prop)
         return cmp == nothing ? false : eval(op)(cmp, val)
      end
         
   end 

   error("The input string couldn't be parsed. Please consult documentation")
end