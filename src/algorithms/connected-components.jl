export connected_components

"""Vertex subtype for connected_components"""
type ComponentVertex <: Vertex
    label
    active::Bool
end

"""Message to advertise a vertex's label"""
immutable RelabelMessage <: Message
    source::Int
    dest::Int
    label::Int
end
RelabelMessage(dest::Int, label::Int) = RelabelMessage(myid(), dest, label)

"""Retrieve the label from a RelabelMessage"""
get_label(x::RelabelMessage) = x.label

"""Broadcast label to all neighbors"""
function broadcast_label(v, adj, mint)
    for nbor in adj
        send_message!(mint, RelabelMessage(nbor, get_label(v)))
    end
end

"""Visitor function for lowest label propogation."""
function lowest_label_visitor(v, adj, mint, mq, data...)
    # Check if this is the first iteration
    if get_label(v) < 0
        # The minimum label is its own label
        set_label!(v, -get_label(v))
        # First iteration; simply broadcast
        broadcast_label(v, adj, mint)
    else
        # Calculate minimum label
        min_label = reduce(min, get_label(v), [get_label(m) for m in mq])
        # If label changes, broadcast. Else deactivate.
        if min_label < get_label(v)
            set_label!(v, min_label)
            broadcast_label(v, adj, mint)
        else
            deactivate!(v)
        end
    end

    # Return vertex
    v
end

"""Forward label propogation."""
function forward_label_prop(gstruct::GraphStruct)
    vlist = [ComponentVertex(-i, true) for i in 1:size(gstruct)[1]]
    vlist = bsp(lowest_label_visitor, vlist, gstruct).xs
    map(get_label, reduce(vcat, [], vlist))
end


###
# TODO: Compute backward adjacencies (requires distributed transposes.)
###
"""Main exported function. Currently works only for undirected graphs"""
function connected_components(gstruct::GraphStruct)
    forward_label_prop(gstruct)
end
