"""BFS Auxiliary structure. Contains the vertex status, distance from seed and parent."""
type BFSAux <: AuxStruct
    active::BitArray
    dists::Vector
    parents::Vector
end
getlayout(::BFSAux) = typelayout(BFSAux, [Bcast(), cutdim(1), cutdim(1), cutdim(1)])
distribute(x::BFSAux) = distribute(x, getlayout(x))

"""
BFS DiscoverVertex message. Sent by an already explored vertex to all vertices adjacent
to it.
"""
type DiscoverVertex <: Message
    source::Int
    dest::Int
    dist::Int
end
source(x::DiscoverVertex) = x.source
dest(x::DiscoverVertex) = x.dest
data(x::DiscoverVertex) = x.dist


"""
BFS visitor. If vertex is not processed if it has already been visited.
When a vertex receives its first discover message, it marks itself visited and explores its
neighbors.
"""
function bfs_visitor{S}(i::Int, graph::DistGraph{S}, aux::BFSAux, messages::MessageQueueList)
    ## If vertex has been visited already, skip processing. (BFS specific behavior).
    aux.dists[i] >= 0 && return
    ## Get the vertex id
    u = vertices(graph)

    ## Process messages
    for m in messages
        if isa(m, DiscoverVertex)
            ## Update vertex information.
            aux.dists[i] = data(m)
            aux.parents[i] = source(m)

            ## Explore neighbors
            for v in find(adj(graph)[:,i])
                send_message(DiscoverVertex(u, v, aux.dists[i]+1))
            end

            ## Deactivate self
            aux.active[i] = false

            ## Exit. A single deactivate message is enough to stop processing.
            return nothing
        end
    end
    nothing
end


"""
BFS Function. Returns (dists, parents).
"""
function bfs{S}(graph::DistGraph{S}, seed::Int = 1)
end
