################################################# FILE DESCRIPTION #########################################################

# This file contains a Linear implemenation of the PropertyModule interface. The module uses dictionaries or user
# defined types depending on the constructor used.

################################################# IMPORT/EXPORT ############################################################

export LinearPM

type LinearPM{V,E} <: PropertyModule{V,E}
   vprops::Dict{Any,DataType}
   eprops::Dict{Any,DataType}
   vdata::Vector
   edata::SparseMatrixCSC

   function LinearPM(vprops::Dict, eprops::Dict, vdata::AbstractVector, edata::SparseMatrixCSC)
      new(vprops, eprops, vdata, edata)
   end

   function LinearPM(nv::Int=0)
      self = new()

      if V == Any
         self.vprops = Dict{Any,DataType}()
         self.vdata = [Dict() for i in 1:nv]
      else
         self.vprops = Dict{Any,DataType}(string(field) => fieldtype(V, field) for field in fieldnames(V))
         self.vdata = [zero(V) for i in 1:nv]
      end

      if E == Any
         self.eprops = Dict{Any,DataType}()
         self.edata = spzeros(Dict, nv, nv)
      else
         self.eprops = Dict{Any,DataType}(string(field) => fieldtype(E, field) for field in fieldnames(E))
         self.edata = spzeros(E, nv, nv)
      end

      self
   end

   function LinearPM(nv::Int, ne::Int)
      self = LinearPM{V,E}(nv)
      sizehint!(self.edata, ne)
      self
   end
end

LinearPM(nv::Int) = LinearPM{Any,Any}(nv)
LinearPM(nv::Int, ne::Int) = LinearPM{Any,Any}(nv,ne)

@inline vprops(x::LinearPM) = x.vprops
@inline eprops(x::LinearPM) = x.eprops
@inline vdata(x::LinearPM) = x.vdata
@inline edata(x::LinearPM) = x.edata

################################################# MISCELLANIOUS #############################################################

function Base.deepcopy(x::LinearPM)
   LinearPM(deepcopy(vprops(x)), deepcopy(eprops(x)), deepcopy(vdata(x)), deepcopy(edata(x)))
end

@inline function check_vprop(x::LinearPM, propname)
   in(propname, vprops(x)) || error("Vertex has no property: $propname")
end

@inline function check_eprop(x::LinearPM, propname)
   in(propname, eprops(x)) || error("Edge has no property: $propname")
end

################################################# MUTATION ##################################################################

# Add nv vertices
function addvertex!(x::LinearPM, nv::Int=1)
   append!(vdata(x), zeros(eltype(vdata(x)), nv))
   x.edata = grow(edata(x), nv)
   nothing
end


# Remove vertex(s)
function rmvertex!(x::LinearPM, v)
   deleteat!(vdata(x), v)
   x.edata = remove_cols(edata(x), v)
   nothing
end


# Add edge(s)
addedge!(x::LinearPM, u::VertexID, v::VertexID) = nothing
addedge!(x::LinearPM, e::EdgeID) = nothing
addedge!(x::LinearPM, es::AbstractVector{EdgeID}) = nothing


# Remove edges(s)
function rmedge!(x::LinearPM, u::VertexID, v::VertexID)
   delete_entry!(edata(x), u, v)
   nothing
end
@inline rmedge!(x::LinearPM, e::EdgeID) = rmedge!(x, e...)

function rmedge!(x::LinearPM, es::AbstractVector{EdgeID})
   for (u,v) in es
      delete_entry!(edata(x), u, v)
   end
end


################################################# PROPERTIES ##############################################################

hasvprop(x::LinearPM, prop) = haskey(vprops(x), prop)
haseprop(x::LinearPM, prop) = haskey(eprops(x), prop)


listvprops(x::LinearPM{Any,Any}) = vprops(x) |> keys |> collect
listeprops(x::LinearPM{Any,Any}) = eprops(x) |> keys |> collect


listvprops{V,E}(x::LinearPM{V,E}) = map(string, fieldnames(V))
listeprops{V,E}(x::LinearPM{V,E}) = map(string, fieldnames(E))


################################################# VALIDATION ###############################################################

###
# VERTEX PROPERTY VALIDATION
###
function propmote_vertex_type!{T}(x::LinearPM{Any,Any}, ::Type{T}, propname)
   vprops(x)[propname] = typejoin(get!(vprops(x), propname, T), T)
   nothing
end

function propmote_vertex_type!{T}(x::LinearPM, ::Type{T}, propname)
   validate_vertex_property(x, propname)
   (T <: vprops(x)[propname]) || error("Illegal data type $T for property $propname")
   nothing
end

propmote_vertex_type!(x::LinearPM, val, propname) = propmote_vertex_type!(x, typeof(val), propname)
propmote_vertex_type!(x::LinearPM, vals::AbstractVector, propname) = propmote_vertex_type!(x, eltype(vals), propname)


###
# EDGE PROPERTY VALIDATION
###
function propmote_edge_type!{T}(x::LinearPM{Any,Any}, ::Type{T}, propname)
   eprops(x)[propname] = typejoin(get!(eprops(x), propname, T), T)
   nothing
end

function propmote_edge_type!{T}(x::LinearPM, ::Type{T}, propname)
   validate_edge_property(x, propname)
   (T <: eprops(x)[propname]) || error("Illegal data type $T for property $propname")
   nothing
end

propmote_edge_type!(x::LinearPM, val, propname) = propmote_edge_type!(x, typeof(val), propname)
propmote_edge_type!(x::LinearPM, vals::AbstractVector, propname) = propmote_edge_type!(x, eltype(vals), propname)

################################################# SUBGRAPH #################################################################

function subgraph{V,E}(x::LinearPM{V,E}, vlist::AbstractVector{VertexID})
   LinearPM{V,E}(copy(vprops(x)), copy(eprops(x)), vdata(x)[vlist], edata(x)[vlist,vlist])
end

# Slow af. But to be fair, this module isn't expected to do this..
function subgraph(x::LinearPM, vlist::AbstractVector{VertexID}, vproplist::AbstractVector)
   vpd = Dict(prop => vprops(x)[prop] for prop in vproplist)
   y = LinearPM{Any,Any}(vpd, copy(eprops(x)), [Dict() for v in vlist], edata(x)[vlist,vlist])
   for prop in vproplist
      vals = getvprop(x, vlist, prop)
      setvprop!(y, :, vals, prop)
   end
   y
end



function subgraph{V,E}(x::LinearPM{V,E}, elist::AbstractVector{EdgeID})
   LinearPM{V,E}(copy(vprops(x)), copy(eprops(x)), deepcopy(vdata(x)), splice_matrix(edata(x), elist))
end

# Slow af. But to be fair, this module isn't expected to do this..
function subgraph(x::LinearPM, elist::AbstractVector{EdgeID}, eproplist::AbstractVector)
   nv = length(vdata(x))
   epd = Dict(prop => eprops(x)[prop] for prop in eproplist)
   y = LinearPM{Any,Any}(copy(vprops(x)), epd, deepcopy(vdata(x)), spzeros(Dict, nv, nv))
   for prop in eproplist
      vals = geteprop(x, elist, prop)
      seteprop!(y, elist, vals, prop)
   end
   y
end


function subgraph{V,E}(x::LinearPM{V,E}, vlist::AbstractVector{VertexID}, elist::AbstractVector{EdgeID})
   M = splice_matrix(edata(x), elist)[vlist,vlist]
   LinearPM{V,E}(copy(vprops(x)), copy(eprops(x)), vdata(x)[vlist], M)
end

_getfield(d::Dict, key) = d[key]
_getfield(d, key) = getfield(d, Symbol(key))

# PLEASE OPTIMIZE ME
function subgraph(
   x::LinearPM,
   vlist::AbstractVector{VertexID},
   elist::AbstractVector{EdgeID},
   vproplist::AbstractVector,
   eproplist::AbstractVector
   )
   nv = length(vlist)

   VD = sizehint!(Vector{Dict}(), nv)

   for v in vlist
      d = Dict()
      for prop in vproplist
         d[prop] = _getfield(vdata(x)[v], prop)
      end
      push!(VD, d)
   end

   sv = splice_matrix(edata(x), elist)[vlist,vlist]
   elist = sizehint!(Vector{EdgeID}(), nnz(sv))
   nzval = sizehint!(Vector{Dict}(), nnz(sv))


   for u in 1 : length(vlist)
      for v in sv.rowval[nzrange(sv, u)]
         d = Dict()
         for prop in eproplist
            d[prop] = _getfield(sv[v,u], prop)
         end
         push!(elist, EdgeID(u,v))
         push!(nzval, d)
      end
   end
   ED = init_spmx(nv, elist, nzval)
   vpd = Dict(prop => vprops(x)[prop] for prop in vproplist)
   epd = Dict(prop => eprops(x)[prop] for prop in eproplist)
   LinearPM{Any,Any}(vpd, epd, VD, ED)
end
