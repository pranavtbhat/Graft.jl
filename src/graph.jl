import ComputeFramework: Bcast, cutdim, typelayout, distribute
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


"""
Core graph representation.
"""
type DistGraph{S<:GraphStruct}
    nv::Int                            # Number of vertices
    vertices::Vector                   # Need to change this to UnitRange eventually
    adj::S
end

"""
Creates a Graph representation. Requires inputs:
- Number of vertices
- A Graph Data Structure which may be an Adjacency List or a Adjacency Matrix
"""
distgraph{S<:GraphStruct}(nv::Int, adj::S) = DistGraph(nv, collect(1:nv), adj)
distgraph{S<:GraphStruct}(adj::S) = DistGraph(size(adj)[1], collect(1:size(adj)[1]), adj)

"""Accessor functions"""
numvertices(x::DistGraph) = x.nv
vertices(x::DistGraph) = x.vertices
adj(x::DistGraph) = x.adj

"""
Methods to get the layout required to get a graph
"""
function getlayout{S<:AdjacencyList}(::DistGraph{S})
    typelayout(DistGraph{S}, [Bcast(), cutdim(1), cutdim(1)])
end

function getlayout{S<:AdjacencyMatrix}(::DistGraph{S})
    typelayout(DistGraph{S}, [Bcast(), cutdim(1), cutdim(2)])
end

"""
Distribute method for graph
"""
distribute{S<:GraphStruct}(x::DistGraph{S}) = distribute(x, get_layout(x))

###
# AUXILIARY GRAPH STRUCTURES
###
"""
Abstract definition of an auxiliary data structure. Each algorithm should define its
own AuxStruct.
"""
abstract AuxStruct

"""All implementations of AuxStruct should define the following methods."""
getlayout(::AuxStruct) = error("No layouts defined")
distribute(::AuxStruct) = error("Distribute not defined")
redistribute(::AuxStruct) = error("redistribute not defined")
