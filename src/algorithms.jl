################################################# FILE DESCRIPTION #########################################################

# This file contains graph algorithms.
 
################################################# IMPORT/EXPORT ############################################################
export
# Traversals
bfs, dfs,
# Connectivity
is_connected, is_strongly_connected, is_weakly_connected, strongly_connected_components, condensation,
# Shortest Paths
a_star, dijkstra_shortest_paths, bellman_ford_shortest_paths, sssp

################################################# INTERNALS ################################################################

type EdgePropInterface <: AbstractArray{Float64, 2}
   nv::Int
   data
   propname
end

function EdgePropInterface(g, propname)
   EdgePropInterface(nv(g), propmod(g), propname)
end

Base.getindex(x::EdgePropInterface, s::Int, d::Int) = geteprop(x.data, s, d, x.propname)
Base.size(x::EdgePropInterface) = (x.nv, x.nv)
@interface Base.transpose(x::EdgePropInterface)
@interface Base.ctranspose(x::EdgePropInterface)


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

################################################# Connectivity ########################################################

if CAN_USE_LG
   is_connected(g::Graph{LightGraphsAM}) = LightGraphs.is_connected(data(adjmod(g)))
   is_strongly_connected(g::Graph{LightGraphsAM}) = LightGraphs.is_strongly_connected(data(adjmod(g)))
   is_weakly_connected(g::Graph{LightGraphsAM})= LightGraphs.is_weakly_connected(data(adjmod(g)))
   strongly_connected_components(g::Graph{LightGraphsAM})= LightGraphs.strongly_connected_components(data(adjmod(g)))
   condensation(g::Graph{LightGraphsAM})= LightGraphsAM(LightGraphs.condensation(data(adjmod(g))))
end

################################################# Shortest Paths ######################################################

if CAN_USE_LG
   a_star(g::Graph{LightGraphsAM}, s::Int64, t::Int64) = LightGraphs.a_star(data(adjmod(g)), s, t)
   a_star(g::Graph{LightGraphsAM}, s::Int64, t::Int64, propname::Symbol) = LightGraphs.a_star(data(adjmod), s, t, EdgePropInterface(g, propname))

   dijkstra_shortest_paths(g::Graph{LightGraphsAM}, s::Int) = LightGraphs.dijkstra_shortest_paths(data(adjmod(g)), s)
   dijkstra_shortest_paths(g::Graph{LightGraphsAM}, s::Int, propname) = LightGraphs.dijkstra_shortest_paths(data(adjmod(g)), s, EdgePropInterface(g, propname))

   bellman_ford_shortest_paths(g::Graph{LightGraphsAM}, s::Int, propname) = LightGraphs.bellman_ford_shortest_paths(data(adjmod(g)), s, EdgePropInterface(g, propname))

   sssp(g::Graph{LightGraphsAM}, s::Int) = dijkstra_shortest_paths(g, s).dists
   sssp(g::Graph{LightGraphsAM}, s::Int, propname) = dijkstra_shortest_paths(g, s, propname).dists
end