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

setproperty!(x::Vertex{VertexProperty}, ::VertexProperty) =
    error("Can't overwrite existing property on $x")

function rmproperty!(x::Vertex)
    x.property = NullProperty()
end
