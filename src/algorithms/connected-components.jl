export connected_components

"""Vertex subtype for connected_components"""
type ComponentVertex <: Vertex
    label
    active::Bool
end

"""Message to advertise a vertex's label"""
type RelabelMessage <: Message
    source::Int
    dest::Int
    label::Int
end
RelabelMessage(dest::Int, label::Int) = RelabelMessage(myid(), dest, label)

"""Retrieve the label from a RelabelMessage"""
get_label(x::RelabelMessage) = x.label

"""Visitor function for lowest label propogation."""
function lowest_label_visitor(v, adj, mint, mq, data...)
    # Check if this is the first iteration
    if get_label(v) < 0
        # The minimum label is its own label
        set_label!(v, -get_label(v))
    else
        # Calculate minimum label
        min_label = round(Int, reduce(min, get_label(v), [get_label(m) for m in mq]))
        if min_label < get_label(v)
            set_label!(v, min_label)
        else
            # skip broadcast??
            deactivate!(v)
        end
    end

    # Broadcast the labels to neighbors
    for nbor in adj
        send_message!(mint, RelabelMessage(nbor, get_label(v)))
    end

    # Return vertex
    v
end

"""Main exported function."""
function connected_components(gstruct::GraphStruct)
    vlist = [ComponentVertex(-i, true) for i in 1:size(gstruct)[1]]
    vlist = bsp(lowest_label_visitor, vlist, gstruct).xs
    map(get_label, reduce(vcat, [], vlist))
end
