import ComputeFramework: Bcast, cutdim, typelayout, distribute
import Base: isequal
export distgraph, num_vertices, vertices, adj

###
# CORE GRAPH STRUCTURES
###
"""
Permitted graph data structures. Each data structure must implement the `get_adj`
method to retreive a vertex's adjacencies.
"""
typealias AdjacencyList Array{Array{Int, 1}, 1}
typealias AdjacencyMatrix AbstractArray{Int, 2}
typealias GraphStruct Union{AdjacencyList, AdjacencyMatrix}

get_adj(x::AdjacencyList, iter::Int) = x[iter]
get_adj(x::AdjacencyMatrix, iter::Int) = x[:,iter]
###
# AUXILIARY GRAPH STRUCTURES
###
"""
Abstract definition of an auxiliary data structure. Each algorithm should define its
own AuxStruct. This structure can be used to store additional information about each
vertex, such as labels, distance from source, etc.

When the graph is created, the Auxiliary strucuture is set to an empty list.
Operations performed on the graph may add auxiliary structures to the graph.

Every auxiliary structure should have an Bool `active` field indicating the status
of the vertex. Additionaly it should implement an `is_active` accessor method.
"""
abstract AuxStruct
is_active(x::AuxStruct) = x.active
activate(x::AuxStruct) = (x.active = true)

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

"""Core accessors """
get_num_vertices(x::DistGraph) = length(x.vertices)
get_vertices(x::DistGraph) = x.vertices
get_struct(x::DistGraph) = x.adj

""" Auxiliary accessors """
has_aux(x::DistGraph) = length(x.aux) > 0  # Check if the graph has auxiliary data attached.
get_aux(x::DistGraph) = x.aux              # Fetch the graph's auxiliary structure. (Unsafe)
take_aux!(x::DistGraph) = (aux = x.aux; x.aux = Vector{AuxStruct}(); aux) # Detach and return the graph's auxiliary structure
set_aux!{A<:AuxStruct}(x::DistGraph, y::Vector{A}) = (x.aux = y; nothing)  # Replace the graph's auxiliary structure.

""" Check if two graphs are equal """
isequal(x::DistGraph, y::DistGraph) = get_vertices(x) == get_vertices(y) && get_struct(x) == get_struct(y) && get_aux(x) == get_aux(y)

""" Status accessors (Unsafe) """
is_active(x::DistGraph, iter::Int) = is_active(get_aux(x)[iter])
get_num_active(x::DistGraph) = mapreduce(is_active, +, 0, get_aux(x))

""" Constructors """
distgraph{S<:GraphStruct}(adj::S) = DistGraph(collect(1:size(adj)[1]), adj, Vector{AuxStruct}())


###
# Interaction with ComputeFramework
###
""" Methods to get the layout required to distribute a graph """
function get_layout{S<:AdjacencyList}(::DistGraph{S})
    typelayout(DistGraph{S}, [cutdim(1), cutdim(1), cutdim(1)])
end

function get_layout{S<:AdjacencyMatrix}(::DistGraph{S})
    typelayout(DistGraph{S}, [cutdim(1), cutdim(2), cutdim(1)])
end

""" Distribute method for graph """
distribute{S<:GraphStruct}(x::DistGraph{S}) = distribute(x, get_layout(x))
