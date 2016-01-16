export AdjacencyList, AdjacencyMatrix, get_adj, get_label, set_label

###
# GRAPH STRUCTURES
###
"""
An lists of lists denoting the neighbors of each vertex.
Eg:
For an undirected graph with vertices: [1,2,3]
and edges:
1 - 2
1 - 3
the AdjacencyList representation is: [[2,3], [1], [1]]

The adjacency list has slow lookup can be iterated through quickly.
"""
typealias AdjacencyList Array{Array{Int, 1}, 1}

"""
A matrix where columns indicate vertices neighbors.
Eg:
For an undirected graph with vertices: [1,2,3]
and edges:
1 - 2
1 - 3
2 - 3
the AdjacencyMatrix representation is:
[
    [false, true, true],
    [true, false, false],
    [true, false, false]
]

The AdjacencyMatrix representation has fast lookup but slower iteration. The type
also permits Sparse Matrices.
"""
typealias AdjacencyMatrix Union{AbstractArray{Bool, 2}, SparseMatrixCSC{Bool,Int}}

"""
Permitted graph data structures:
- AdjacencyList
- AdjacencyMatrix
"""
typealias GraphStruct Union{AdjacencyList, AdjacencyMatrix}

###
# ACCESSORS FOR GRAPH STRUCTURES
###

"""Fetch a vertex's neighbors"""
get_adj(x::AdjacencyList, v::Int) = x[v]
get_adj(x::AdjacencyMatrix, v::Int) = find(x[:,v])

###
# Vertex Definition
###
"""
Abstract type representing a vertex/node in a graph. Each subtype should have the following fields:
- label  : External vertex identifier.
- active : A Bool indicating whether the vertex is active or not.
"""
abstract Vertex

###
# BASIC ACCESSORS FOR VERTEX SUBTYPES.
###
"""Retrieve a vertex's label"""
get_label(x::Vertex) = x.label

"""Modify a vertex's label"""
function set_label(x::Vertex, label)
    x.label = label
end

"""Check if the given vertex is active(Internal Method)"""
is_active(x::Vertex) = x.active

"""Activate a vertex(Internal Method)"""
function activate!(x::Vertex)
    x.active = true
end

"""Deactivate a vertex(Internal Method)"""
function activate!(x::Vertex)
    x.active = false
end
