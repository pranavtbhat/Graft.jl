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

The adjacency list has slow lookup, but can be iterated through quickly.
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
typealias AdjacencyMatrix Union{AbstractArray{Bool, 2}}

"""Null structure to indicate the absence of an adjacency list."""
typealias NullStruct Void

"""
Permitted graph data structures:
- AdjacencyList
- AdjacencyMatrix
"""
typealias GraphStruct Union{AdjacencyList, AdjacencyMatrix, NullStruct}

###
# ACCESSORS FOR GRAPH STRUCTURES
###

"""Fetch a vertex's neighbors"""
get_adj(x::SparseMatrixCSC, v::Int) = x[:,v].nzind # Temporary fix.
get_adj(x::AdjacencyList, v::Int) = x[v]
get_adj(x::AdjacencyMatrix, v::Int) = find(x[:,v])


###
# VERTEX PROPERY
###
"""An Algorithm-dependant extension that adds further detail to a vertex"""
abstract VertexProperty

"""Type indicating the absence of a property"""
 immutable NullProperty <: VertexProperty
 end

###
# Vertex Definition
###
"""Type representing a vertex/node in a graph."""
type Vertex{P<:VertexProperty}
    id::Int                                     # An internal vertex identifier.
    label::AbstractString                       # External vertex identifier.
    active::Bool                                # A Bool indicating whether the vertex is active or not.
    fadjlist::Vector{VertexID}                  # A list of VertexIDs indicating forward adjacencies.
    badjlist::Vector{VertexID}                  # A list of VertexIDs indicating back adjacencies.
    property::P                                 # Algorithm-dependant extension.
end

###
# GETTERS
###
getid(x::Vertex) = x.id
getlabel(x::Vertex) = x.label
isactive(x::Vertex) = x.active
getfadj(x::Vertex) = x.fadjlist
getbadj(x::Vertex) = x.badjlist
getproperty(x::Vertex) = x.property

###
# SETTERS
###
function setlabel!(x::Vertex, label::AbstractString)
    x.label = label
end

function activate!(x::Vertex)
    x.active = true
end

function deactivate!(x::Vertex)
    x.active = false
end

function setfadj!(x::Vertex, fadjlist::Vector{VertexID})
    x.fadjlist = fadjlist
end

function setbadj!(x::Vertex, badjlist::Vector{VertexID})
    x.badjlist = badjlist
end

function setproperty!(x::Vertex{NullProperty}, property::VertexProperty)
    x.property = property
end

setproperty(x::Vertex{VertexProperty}, ::VertexProperty) =
    error("Can't overwrite existing property on $x")

function rmproperty(x::Vertex)
    x.property = NullProperty()
end
