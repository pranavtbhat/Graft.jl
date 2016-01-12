export complete_graph, rand_graph, rand_digraph
"""Generate a complete graph in adjacency matrix format."""
function complete_graph(nv::Int)
    trues(nv,nv)
end

"""Generate a undirected random graph with a given approximate density, in sparse matrix format"""
function rand_graph(nv::Int, d::Float64)
    m = sprandbool(nv, nv, d)
    triu(m) + triu(m,1)'
end

"""Generate a directed random graph with a given approximate density, in sparse matrix format"""
function rand_digraph(nv::Int, d::Float64)
    sprandbool(nv, nv, d)
end
