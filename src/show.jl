import Base.show

# Debug for DistGraph
function show{S<:AdjacencyList}(io::IO, x::DistGraph{S})
    write(io, "Graph{$(length(get_vertices(x))), $(round(Int, mapreduce((y)->length(find(y)), +, 0, get_adj(x))))}")
end
