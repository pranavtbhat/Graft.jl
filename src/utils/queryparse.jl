################################################# FILE DESCRIPTION ############################################################
# This file contains methods to parse query strings
################################################# IMPORT/EXPORT ###############################################################


################################################# VERTEX QUERY ################################################################


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

################################################# EDGE QUERY ##################################################################

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
