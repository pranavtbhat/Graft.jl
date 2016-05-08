export parsegraph

""" 
Constructor for Edge Lists
The input file shou
The input file should data in the following format:
<num_vertices> <num_edges>
<vertex_id> <vertex_prop_1> <val_1> <vertex_prop_2> <val_2> ...
.
.
.
<from_vertex_id> <to_vertex_id> <edge_property_1> <val_1> <edge_property_2> <val_2> ...
.
.
.
EOF
"""
function parsegraph(filename::ASCIIString)
	file = open(filename)
	nv, ne = map(x->parse(Int, x), split(readline(file), " "))
	
	data = NDSparse(VertexID[], VertexID[], PropID[], WithDefault(Any[], nothing))

	vprop_fmap = Dict{ASCIIString, VertexID}()
	vprop_rmap = Dict{VertexID, ASCIIString}()

	eprop_fmap = Dict{ASCIIString, EdgeID}("id" => 1)
	eprop_rmap = Dict{EdgeID, ASCIIString}(1 => "id") 


	ne_i = 1
	vprop_i = 1
	eprop_i = 2

	while !eof(file)
		line = strip(readline(file), '\n')

		args = split(line, " ")
		(length(args) == 0 || length(line) == 0) && continue

		if length(args) % 2 == 1 # It's a vertex description
			v = parse(Int, args[1])

			for i in eachindex(args)[2:2:end-1]
				prop = args[i]
				val = args[i+1]
				# Check if prop exists
				if !haskey(vprop_fmap, prop)
					vprop_fmap[prop] = vprop_i
					vprop_rmap[vprop_i] = prop
					vprop_i += 1
				end
				data[v, v, vprop_fmap[prop]] = isnumber(val) ? parse(Int, val) : val
			end
		elseif length(args) % 2 == 0 # It's an edge description
			v1, v2 = map(x->parse(Int, x), args[1:2])
			# Register Edge
			data[v1, v2, 1] = ne_i
			ne_i += 1

			for i in eachindex(args)[3:2:end-1]
				prop = args[i]
				val = args[i+1]
				# Check if prop exists
				if !haskey(eprop_fmap, prop)
					eprop_fmap[prop] = eprop_i
					eprop_rmap[eprop_i] = prop
					eprop_i += 1
				end
				data[v1, v2, eprop_fmap[prop]] = isnumber(val) ? parse(Int, val) : val
			end
		end
	end
	IndexGraph(nv, ne, data, vprop_fmap, vprop_rmap, eprop_fmap, eprop_rmap)
end