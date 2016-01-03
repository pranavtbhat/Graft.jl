import ComputeFramework: Bcast, cutdim, typelayout, distribute
import Base: isequal
export distgraph, num_vertices, vertices, adj

###
# CORE GRAPH STRUCTURES
###
"""
Permitted graph data structures.
"""
typealias AdjacencyList Array{Array{Int, 1}, 1}
typealias AdjacencyMatrix AbstractArray{Int, 2}
typealias GraphStruct Union{AdjacencyList, AdjacencyMatrix}

###
# AUXILIARY GRAPH STRUCTURES
###
"""
Abstract definition of an auxiliary data structure. Each algorithm should define its
own AuxStruct. This structure can be used to store additional information about each
vertex, such as labels, distance from source, etc.

When the graph is created, the Auxiliary strucuture is set to an empty list.
Operations performed on the graph may add auxiliary structures to the graph.
"""
abstract AuxStruct

###
# GRAPH REPRESENTATION
###
"""
Graph representation that combines the core and auxiliary structures. The constructor
should not be invoked directly.
"""
type DistGraph{S}
    vertices::Vector                   # List of vertices present in the (sub)graph.
    adj::S                             # Graph data structure indicating adjacencies.
    aux::Vector                        # Array of auxiliary structures describing vertices.
end
get_vertices(x::DistGraph) = x.vertices
get_adj(x::DistGraph) = x.adj

has_aux(x::DistGraph) = length(x.aux) > 0  # Check if the graph has auxiliary data attached.
get_aux(x::DistGraph) = x.aux              # Fetch the graph's auxiliary structure. (Unsafe)
take_aux!(x::DistGraph) = (aux = x.aux; x.aux = Vector{AuxStruct}(); aux) # Detach and return the graph's auxiliary structure
set_aux!{A<:AuxStruct}(x::DistGraph, y::Vector{A}) = (x.aux = y; nothing)  # Replace the graph's auxiliary structure.

isequal(x::DistGraph, y::DistGraph) = get_vertices(x) == get_vertices(y) && get_adj(x) == get_adj(y) && get_aux(x) == get_aux(y)

"""
Converts an adjacency matrix or adjacency list into a graph.
"""
distgraph{S<:GraphStruct}(adj::S) = DistGraph(collect(1:size(adj)[1]), adj, Vector{AuxStruct}())
"""
Methods to get the layout required to distribute a graph
"""
function get_layout{S<:AdjacencyList}(::DistGraph{S})
    typelayout(DistGraph{S}, [cutdim(1), cutdim(1), cutdim(1)])
end

function get_layout{S<:AdjacencyMatrix}(::DistGraph{S})
    typelayout(DistGraph{S}, [cutdim(1), cutdim(2), cutdim(1)])
end

"""
Distribute method for graph
"""
distribute{S<:GraphStruct}(x::DistGraph{S}) = distribute(x, get_layout(x))
