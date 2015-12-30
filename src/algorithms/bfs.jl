###
# Breadth first search auxiliary structure
###
type BFSAux <: AuxStruct
    nv::Int
    active::BitArray{1}
    mlist
    dists::Vector{Int}
    parents::Vector{Int}
end

###
# BFS ActivateMessage
###
type DiscoverVertex <: Message
    source::Int
    dest::Int
    dist::Int
end

function process_message(m::DiscoverVertex, aux::BFSAux)
    if aux.dists[m.dest] < 0
        aux.active[m.dest] = true
        aux.dists[m.dest] = m.dest
        aux.parents[m.dest] = m.source
    end
end

function activate(u::Int, v::Int, dist::Int, aux::BFSAux)
    push!(aux.mlist[getParentProc(aux.nv, v)-1], DiscoverVertex(u,v,dist))
end


##
# Breadth first search visitor
###
# function bfsVisitor{S}(graph::DistGraph{S}, aux::BFSAux)
