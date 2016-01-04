"""
Define an auxiliary structure with a label field
"""
type LowestLabelAux <: AuxStruct
    active::Bool
    label::Int
end
get_label(x::LowestLabelAux) = x.label
set_label(x::LowestLabelAux, label::Int) = (x.label = label)

"""
Define a message structure.
"""
type LabelMessage <: Message
    dest::Int
    label::Int
end
get_label(x::LabelMessage) = x.label

"""
Visitor function for lowest label propogation.
"""
function lowest_label_visitor(u::Int, adj::Vector{Int}, aux::AuxStruct, messages::MessageQueue)
    # If vertex was previously inactive, activate it.
    activate(aux)
    # Get lowest neighboring label
    min_label = round(Int, reduce(min, Inf, [get_label(m) for m in messages]))
    # If new label is smaller than the old label, call set_label. Else deactivate
    if min_label < get_label(aux)
        set_label(aux, min_label)
        for v in adj
            sendMessage(LabelMessage(min_label), v)
        end
    else
        deactivate(aux)
    end
end
