################################################# FILE DESCRIPTION #########################################################

# This file contains graph algorithms.

################################################# IMPORT/EXPORT ############################################################
export
# External interfaces
hoplist, hoptree, hopgraph, mutualcount, mutual
################################################# BFSLIST ##################################################################

""" Standard BFS implementation that returns a parent vector """
function bfs(g::Graph, seed::Vector{Int}, hopend::Number=Inf)
   N = nv(g)

   parvec = fill(-1, N)
   parvec[seed] = 0

   Q = sizehint!(copy(seed), N)
   Q_ = size
   adj = sizehint!(Vector{Int}(N), N)

   nhops = 1

   lsize = length(seed)
   lcount = 0

   while !isempty(Q) && nhops <= hopend
      u = shift!(Q)

      for v in fadj!(g, u, adj)
         if parvec[v] == -1
            parvec[v] = u
            push!(Q, v)
         end
      end

      lcount += 1

      if lcount == lsize
         lsize = length(Q)
         lcount = 0
         nhops += 1
      end
   end

   return parvec
end

bfs(g::Graph, seed::AbstractVector, nhops::Number=Inf) = bfs(g, collect(seed), nhops)
bfs(g::Graph, seed::Int, nhops::Number=Inf) = bfs(g, Int[seed], nhops)

################################################# BFSLIST ##################################################################

""" Get the list of vertices at a certain distance from the seed """
function bfs_list(g::Graph, seed::Vector{Int}, hopstart::Int=1, hopend::Number=Inf)
   N = nv(g)
   vs = sizehint!(Vector{Int}(0), N)

   visited = falses(N)
   visited[seed] = true

   Q = sizehint!(copy(seed), N)
   adj = sizehint!(Vector{Int}(0), N)

   nhops = 1

   lsize = length(seed)
   lcount = 0

   # Visit one entire level of level_size elements
   while !isempty(Q) && nhops <= hopend
      u = shift!(Q)

      # Visit u's adjacencies
      for v in fadj!(g, u, adj)
         # If v hasn't been visited, visit it
         if !visited[v]
            visited[v] = true

            # Return v if it's in the hoprange
            if nhops >= hopstart
               push!(vs, v)
            end
            push!(Q, v)
         end
      end

      lcount += 1

      if lcount == lsize
         lsize = length(Q)
         lcount = 0
         nhops += 1
      end
   end

   return vs
end

bfs_list(g::Graph, seed::AbstractVector, hopstart::Int=1, hopend::Number=Inf) = bfs_list(g, collect(seed), hopstart, hopend)
bfs_list(g::Graph, seed::Int, hopstart::Int=1, hopend::Number=Inf) = bfs_list(g, [seed], hopstart, hopend)

"""
Get a list of vertices at a certain hop distance from a labelled vertex
"""
function hoplist(g::Graph, x, hopstart::Int, hopend::Number=Inf)
   encode(g, bfs_list(g, decode(g, x), hopstart, hopend))
end

################################################# BFSTREE ###############################################################

"""
Returns a BFS tree, containing explored vertices and only tree edges.
"""
function bfs_tree(g::Graph, seed::Int, hopend::Number=Inf)
   parvec = bfs(g, seed, hopend)

   us = sizehint!(Int[], nv(g))
   vs = sizehint!(Int[], nv(g))

   for v in eachindex(parvec)
      u = parvec[v]
      if u > 0
         push!(us, u)
         push!(vs, v)
      end
   end
   vlist = vcat(seed, vs)
   eit = EdgeIter(length(us), us, vs)

   subgraph(g, vlist, eit)
end

"""
Get the bfs tree starting from the input labelled vertex, and ending at a certain hop distance
"""
function hoptree(g::Graph, x, hopend::Number=Inf)
   bfs_tree(g, decode(g, x), hopend)
end

################################################# BFSSUBGRAPH #############################################################

"""
Returns a BFS subgraph, containing explored vertices and all edges between
them
"""
function bfs_subgraph(g::Graph, seed, hopend::Number=Inf)
   vs = append!(bfs_list(g, seed, 1, hopend), seed)
   subgraph(g, vs)
end

"""
Get a subgraph containing vertices and edges within a certain hop distance from the input labelled
vertex
"""
function hopgraph(g::Graph, x, hopend::Number=Inf)
   bfs_subgraph(g, decode(g, x), hopend)
end

################################################# MUTUAL FRIENDS ###########################################################

# Hacky to ensure performance
function count_mutual_adj(g::Graph, u::VertexID, v::VertexID)
   x = indxs(g)

   i = x.colptr[u]
   j = x.colptr[v]

   ei = x.colptr[u+1] - 1
   ej = x.colptr[v+1] - 1

   count = 0

   while i <= ei && j <= ej
      @inbounds vi = x.rowval[i]
      @inbounds vj = x.rowval[j]

      if vi < vj
         i += 1
      elseif vi == vj
         count += 1
         i += 1
         j += 1
      else
         j += 1
      end
   end

   return count
end

mutualcount(g::Graph, ul, vl) = count_mutual_adj(g, decode(g, ul), decode(g, vl))

function mutual_adj(g::Graph, u::VertexID, v::VertexID)
   x = indxs(g)

   aru = nzrange(x, u)
   arv = nzrange(x, v)

   i = start(aru)
   j = start(arv)

   res = sizehint!(Int[], count_mutual_adj(g, u, v))

   while i in aru && j in arv
      if x.rowval[i] < x.rowval[j]
         i += 1
      elseif x.rowval[i] == x.rowval[j]
         push!(res, x.rowval[i])
         i += 1
         j += 1
      else
         j += 1
      end
   end

   return res
end

mutual(g::Graph, ul, vl) = encode(g, mutual_adj(g, decode(g, ul), decode(g, vl)))
