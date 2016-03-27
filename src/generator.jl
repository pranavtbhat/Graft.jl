export cgraph, rgraph, rdigraph, rwgraph, rwdigraph

"""Generate a complete graph in adjacency matrix format."""
function cgraph(nv::Int)
    sparse(trues(nv,nv))
end

"""Generate a undirected random graph with a given approximate number of edges, in sparse matrix format"""
function rgraph(nv::Int, ane::Int)
    m = sprandbool(nv, nv, ane/(nv^2))
    triu(m,1) | triu(m,1)'
end

"""Generate a directed random graph with a given approximate density, in sparse matrix format"""
function rdigraph(nv::Int, ane::Int)
    m = sprandbool(nv, nv, ane/(nv^2))
    triu(m,1) | tril(m,-1)
end

"""Generate a undirected weighted random graph with a given approximate number of edges and a bound on weights,
in sparse matrix format"""
function rwgraph(nv::Int, ane::Int, wb::Int)
    m = round(Int, sprand(nv, nv, ane/(nv^2)) * wb)
    triu(m,1) | triu(m,1)'
end

"""Generate a directed weighted random graph with a given approximate number of edges and a bound on weights,
in sparse matrix format"""
function rwdigraph(nv::Int, ane::Int, wb::Int)
    m = round(Int, sprand(nv, nv, ane/(nv^2)) * wb)
    triu(m,1) | tril(m,-1)
end
