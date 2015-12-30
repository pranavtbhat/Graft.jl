import Base.show

#Debug for DistGraph
function show(io::IO, x::DistGraph)
    write(io, "Graph{$(length(vertices(x))), $(length(find(adj(x))))}")
end
