export bfs

"""Serial single source BFS"""
function bfs(g::SparseMatrixCSC{Bool,Int64}, src::Int)
    nv = size(g)[1]
    parvec = zeros(Int, nv)
    parvec[src] = 1
    newlen = 1
    oldlen = -1
    while oldlen != newlen
        parvec = g * parvec
        oldlen = newlen
        newlen = length(find(parvec))
    end
    parvec
end
