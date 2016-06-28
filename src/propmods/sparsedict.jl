################################################# FILE DESCRIPTION #########################################################

# This file contains a SparseMatrix implemenation of the PropertyModule interface. The module uses dictionaries or user 
# defined types depending on the constructor used.

################################################# IMPORT/EXPORT ############################################################

export SparseDictPM

type SparseDictPM{V,E} <: PropertyModule{V,E}
   vprops::Set{Any}
   eprops::Set{Any}
   vdata::Vector
   edata::SparseMatrixCSC
end

function SparseDictPM(nv::Int=0)
   SparseDictPM{Any,Any}(Set{Any}(), Set{Any}(), [Dict() for i in 1:nv], spzeros(Dict, nv, nv))
end

@inline vprops(x::SparseDictPM) = x.vprops
@inline eprops(x::SparseDictPM) = x.eprops
@inline vdata(x::SparseDictPM) = x.vdata
@inline edata(x::SparseDictPM) = x.edata

# Set zero to Dict().
Base.zero(::Type{Dict}) = Dict()

################################################# INTERNAL IMPLEMENTATION ##################################################

function Base.deepcopy(x::SparseDictPM)
   SparseDictPM(deepcopy(vprops(x)), deepcopy(eprops(x)), deepcopy(vdata(x)), deepcopy(edata(x)))
end



function addvertex!(x::SparseDictPM, nv::Int=1)
   append!(vdata(x), [Dict() for i in 1:nv])
   x.edata = grow(edata(x), nv)
   nothing
end



function rmvertex!(x::SparseDictPM, v)
   deleteat!(vdata(x), v)
   x.edata = remove_cols(edata(x), v)
   nothing
end



function addedge!(x::SparseDictPM, u::VertexID, v::VertexID)
   edata(x)[v,u] = Dict()
   nothing
end
@inline addedge!(x::SparseDictPM, e::EdgeID) = addedge!(x, e...)

function addedge!(x::SparseDictPM, es::AbstractVector{EdgeID})
   for (u,v) in es
      edata(x)[v,u] = Dict()
   end
end



function rmedge!(x::SparseDictPM, u::VertexID, v::VertexID)
   delete_entry!(edata(x), u, v)
   nothing
end
@inline rmedge!(x::SparseDictPM, e::EdgeID) = rmedge!(x, e...)

function rmedge!(x::SparseDictPM, es::AbstractVector{EdgeID})
   for (u,v) in es
      delete_entry!(edata(x), u, v)
   end
end



listvprops(x::SparseDictPM) = collect(vprops(x))
listeprops(x::SparseDictPM) = collect(eprops(x))


# Get all properties belonging to a vertex
@inline getvprop(x::SparseDictPM, v::VertexID) = vdata(x)[v]

# Get a dictionary of vertex properties for an input vertex list
@inline getvprop(x::SparseDictPM, vlist::AbstractVector{VertexID}) = vdata(x)[vlist]

# Get the value for a property for a vertex
function getvprop(x::SparseDictPM, v::VertexID, propname)
   get(getvprop(x, v), propname, nothing)
end

# Get the value for a property for a list of vertices
function getvprop(x::SparseDictPM, vlist::AbstractVector{VertexID}, propname)
   map(v->getvprop(x, v, propname), vlist)
end



# Get all properties belonging to an edge
@inline geteprop(x::SparseDictPM, u::VertexID, v::VertexID) = edata(x)[v,u]
@inline geteprop(x::SparseDictPM, e::EdgeID) = geteprop(x, e...)

# Get the value of a property for an edge
function geteprop(x::SparseDictPM, u::VertexID, v::VertexID, propname)
   get(geteprop(x, u, v), propname, nothing)
end
@inline geteprop(x::SparseDictPM, e::EdgeID, propname) = geteprop(x, e..., propname)

# Get a dictionary of edge properties for an input edge list
function geteprop(x::SparseDictPM, elist::AbstractVector{EdgeID})
   map(e->geteprop(x, e), elist)
end

# Get the value of property for an input edge list
function geteprop(x::SparseDictPM, elist::AbstractVector{EdgeID}, propname)
   map(e->geteprop(x, e, propname), elist)
end


# Set all properties for a vertex.
function setvprop!(x::SparseDictPM, v::VertexID, d::Dict)
   merge!(vdata(x)[v], d)
   push!(vprops(x), keys(d)...)
   nothing
end

# Set all properties for a list of vertices.
function setvprop!(x::SparseDictPM, vlist::AbstractVector{VertexID}, dlist::Vector)
   for (v,d) in zip(vlist,dlist)
      setvprop!(x, v, d)
   end
end

# Set a property of a single vertex.
function setvprop!(x::SparseDictPM, v::VertexID, val, propname)
   vdata(x)[v][propname] = val
   push!(vprops(x), propname)
   nothing
end

# Set a property for a list of vertices
function setvprop!(x::SparseDictPM, vlist::AbstractVector{VertexID}, vals::Vector, propname)
   for (v,val) in zip(vlist,vals)
      vdata(x)[v][propname] = val
   end
   push!(vprops(x), propname)
   nothing
end

# Map onto a property for a list of vertices
function setvprop!(x::SparseDictPM, vlist::AbstractVector{VertexID}, f::Function, propname)
   setvprop!(x, vlist, map(f, vlist), propname)
end

# Set a property for all vertices
function setvprop!(x::SparseDictPM, ::Colon, vals::Vector, propname)
   for (d,val) in zip(vdata(x), vals)
      d[propname] = val
   end
   push!(vprops(x), propname)
end

# map onto a property for all vertices
function setvprop!(x::SparseDictPM, ::Colon, f::Function, propname)
   for v in eachindex(vdata(x))
      vdata(x)[v][propname] = f(v)
   end
   push!(vprops(x), propname)
end



# Set all properties for an edge
function seteprop!(x::SparseDictPM, u::VertexID, v::VertexID, d::Dict)
   edata(x)[v,u] = merge!(edata(x)[v,u], d)
   push!(eprops(x), keys(d)...)
   nothing
end
@inline seteprop!(x::SparseDictPM, e::EdgeID, d::Dict) = seteprop!(x, e..., d)

# Set all properties for a list of edges
function seteprop!(x::SparseDictPM, elist::AbstractVector{EdgeID}, dlist::Vector)
   for (e,d) in zip(elist,dlist)
      seteprop!(x, e, d)
   end
end

# Set a proprty for an edge
function seteprop!(x::SparseDictPM, u::VertexID, v::VertexID, val, propname)
   d = edata(x)[v,u]
   d[propname] = val
   edata(x)[v,u] = d
   push!(eprops(x), propname)
   nothing
end
@inline seteprop!(x::SparseDictPM, e::EdgeID, val, propname) = seteprop!(x, e..., val, propname)

# Set a property for a list of edges
function seteprop!(x::SparseDictPM, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   for (e,val) in zip(elist,vals)
      seteprop!(x, e, val, propname)
   end
end

# Map onto a property for a list of edges
function seteprop!(x::SparseDictPM, elist::AbstractVector{EdgeID}, f::Function, propname)
   for e in elist
      seteprop!(x, e, f(e...), propname)
   end
end

# Set a property for all edges
function seteprop!(x::SparseDictPM, ::Colon, elist::AbstractVector{EdgeID}, vals::Vector, propname)
   seteprop!(x, elist, vals, propname)
end

# Map onto a property for all edges
function seteprop!(x::SparseDictPM, ::Colon, elist::AbstractVector{EdgeID}, f::Function, propname)
   seteprop!(x, elist, f, propname)
end

################################################# SUBGRAPH #################################################################

function subgraph(x::SparseDictPM, vlist::AbstractVector{VertexID})
   SparseDictPM{Any,Any}(copy(vprops(x)), copy(eprops(x)), vdata(x)[vlist], edata(x)[vlist,vlist])
end

function subgraph(x::SparseDictPM, elist::AbstractVector{EdgeID})
   sv = edata(x)
   evals = [sv[v,u] for (u,v) in elist]
   nv = length(vdata(x))
   SparseDictPM{Any,Any}(copy(vprops(x)), copy(eprops(x)), deepcopy(vdata(x)), init_spmx(nv, elist, evals))
end