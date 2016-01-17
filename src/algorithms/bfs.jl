export bfs

"""Vertex subtype for Breadth First Search"""
type BFSVertex <: Vertex
    label
    active::Bool
    dist::Int
    parent
end

"""Fetch a vertex's distance from seed"""
get_dist(x::BFSVertex) = x.dist

"""Fetch a vertex's parent in the BFS tree"""
get_parent(x::BFSVertex) = x.parent

"""Set a vertex's distance from the seed"""
function set_dist!(x::BFSVertex, dist::Int)
    x.dist = dist
end

"""Set a vertex's parent in the BFS tree"""
function set_parent!(x::BFSVertex, parent)
    x.parent = parent
end

"""Message sent by an already explored vertex to all vertices adjacent to it."""
immutable DiscoverMessage <: Message
    source                 # Source Vertex!
    dest::Int                   # Destination Vertex
    dist::Int                   # Distance from seed.
end

"""Retrieve the source vertex from a DiscoverMessage"""
get_source(x::DiscoverMessage) = x.source

"""Retrieve the distance from a DiscoverMessage"""
get_dist(x::DiscoverMessage) = x.dist

"""Broadcast distance to all neighbors"""
function bfs_broadcast(v, adj, mint, distmx=nothing)
    for nbor in adj
        send_message!(mint, DiscoverMessage(get_label(v), nbor, get_dist(v)+1))
    end
end

"""BFS visitor. The vertex is not processed if it has already been visited."""
function bfs_visitor(v, adj, mint, mq, data...)
    # If vertex has already been visited before, simply deactivate.
    if get_parent(v) >= 0
        deactivate!(v)
        return v
    end

    # Check if the vertex is an unexplored seed:
    if get_dist(v) == 0
        # set parent to 0
        set_parent!(v, 0)
        # broadcast dist to neighbors
        bfs_broadcast(v, adj, mint)
        deactivate!(v)
    else
        # Non seed vertex. Check if there are incoming messages and deactivate.
        if !isempty(mq)
            # If there are messages, find the closest source.
            min_dist, pos = findmin(map(get_dist,mq))
            src = get_source(mq[pos])
            set_dist!(v, min_dist)
            set_parent!(v, src)

            # Broadcast new dist
            bfs_broadcast(v, adj, mint)

            # Deactivate
            deactivate!(v)
        end
    end

    v
end


"""
BFS Function. Returns (dists, parents).
"""
function bfs(gstruct::GraphStruct, seeds::Vector{Int} = [1])
    vlist = [BFSVertex(i, false, -1, -1) for i in 1:size(gstruct)[1]]

    # Initialize all seed vertices
    for seed in seeds
        activate!(vlist[seed])
        set_dist!(vlist[seed], 0)
    end

    vlist = bsp(bfs_visitor, vlist, gstruct).xs
    vlist = reduce(vcat, [], vlist)
    (map(get_dist, vlist), map(get_parent,vlist))
end
