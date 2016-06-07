################################################# FILE DESCRIPTION #########################################################

# This file contains graph algorithms.
 
################################################# IMPORT/EXPORT ############################################################
export
# Traversals
bfs, dfs

################################################# TRAVERSALS ##############################################################


################################################# TRAVERSALS ###############################################################

function bfs(g::Graph, seed)
   N = nv(g)

   parvec = Array(Int, N)
   fill!(parvec, -1)
   parvec[seed] = 0

   Q = Deque(N)
   push!(Q, seed)

   u = 0

   while !isempty(Q)
      u = shift!(Q)
      @inbounds for v in fadj(g, u)
         parvec[v] != -1 && continue
         parvec[v] = u
         push!(Q, v)
      end
   end

   parvec
end

function dfs(g::Graph, root)
   N = nv(g)

   parvec = fill(-1, N)
   parvec[root] = 0

   order = fill(-1, N)

   S = Stack(N)
   push!(S, root)

   count = 0
   u = 0

   while !isempty(S)
      u = pop!(S)
      order[u] == -1 || continue

      order[u] = count
      count += 1

      for v in fadj(g, u)
         parvec[v] == -1 || continue
         parvec[v] = u
         push!(S, v)
      end
   end

   parvec, order
end