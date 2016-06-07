################################################# FILE DESCRIPTION #########################################################

# This file contains graph typealiases and random graph generation methods.

################################################# IMPORT/EXPORT ############################################################
export
# Typealiases
SimpleGraph,
# Random Generation
randgraph


################################################# TYPE ALIASES #############################################################

typealias SimpleGraph Graph{LightGraphsAM,DictPM{ASCIIString,Any}}

################################################# RANDOM GENERATION ########################################################

function randgraph{AM,PM}(
   ::Type{Graph{AM,PM}},
   nv::Int,
   ne::Int,
   vprops::Vector{Symbol} = [:date, :first_name, :last_name, :address, :email],
   eprops::Vector{Symbol} = [:color_name]
   )
   
   g = Graph{AM,PM}(nv, ne)

   for u in 1 : nv
      for vprop in vprops
         setvprop!(g, u, string(vprop), getfield(Faker, vprop)())
      end
      

      for v in fadj(g, u)
         for eprop in eprops
            seteprop!(g, u, v, string(eprop), getfield(Faker, eprop)())
         end
      end
   end
   g
end




################################################# DISPLAY  #################################################################

function Base.show{AM,PM}(io::IO, g::Graph{AM,PM})
   write(io, "Graph{$AM,$PM} with $(nv(g)) vertices and $(ne(g)) edges")
end

