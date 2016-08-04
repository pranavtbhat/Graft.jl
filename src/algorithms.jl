################################################# FILE DESCRIPTION #########################################################

# This file contains graph algorithms.

################################################# IMPORT/EXPORT ############################################################
export
# Traversals
bfs_list, bfs_subgraph

################################################# BFSLIST ##################################################################

function bfslist(g::Graph, seed::Vector{Int}; nhops::Number=Inf)
   N = nv(g)

   parvec = fill(-1, N)
   parvec[seed] = 0

   Q = sizehint!(copy(seed), N)

   adj = sizehint!(Vector{Int}(0), N)

   while !isempty(Q) && nhops > 0
      level_size = length(Q)

      # Visit one entire level of level_size elements
      for i in 1 : level_size
         u = shift!(Q)

         # Visit u's adjacencies
         for v in fadj!(g, u, adj)
            # If v hasn't been visited, visit it
            if parvec[v] != -1
               parvec[v] = u
               push!(Q, v)
            end
         end
      end

      nhops -= 1
   end

   return parvec
end

bfslist(g::Graph, seed::AbstractVector) = bfs(g, collect(seed))
bfslist(g::Graph, seed::Int) = bfs(g, Int[seed])

################################################# BFSSUBGRAPH ##############################################################

function bfssubgraph(g::Graph, seed)
   parvec = bfs(g, seed)
   us = sizehint!(Int[], nv(g))
   vs = sizehint!(Int[], nv(g))

   for v in eachindex(parvec)
      u = parvec[i]
      if u > 0
         push!(us, u)
         push!(vs, v)
      end
   end

   subgraph(g, vs, EdgeIter(length(us), us, vs))
end
