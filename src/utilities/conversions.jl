export to_list, to_matrix

"""Convert an AdjacencyMatrix into a AdjacencyList representation"""
to_list(x::AdjacencyMatrix) = [get_adj(x, iter) for iter in 1:size(x)[2]]

"""Convert an AdjacencyList into an AdjacencyMatrix representation"""
function to_matrix(x::AdjacencyList)
    len, = size(x)
    m = falses(len, len)
    for i in eachindex(x)
        for j in get_adj(x,i)
            m[j,i] = true
        end
    end
    m
end
