################################################# FILE DESCRIPTION #########################################################

# This file contains graph algorithms.

################################################# IMPORT/EXPORT ############################################################
export
# Traversals
bfs, bfs_subgraph, dfs, dfs_subgraph,
# Connectivity
is_connected, is_strongly_connected, is_weakly_connected, strongly_connected_components, condensation,
# Shortest Paths
a_star, dijkstra_shortest_paths, bellman_ford_shortest_paths, sssp,
# Centrality
betweenness_centrality, degree_centrality, indegree_centrality, outdegree_centrality,
closeness_centrality, katz_centrality, pagerank

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

function bfs(g::Graph, seed::Vector{Int})
   N = nv(g)

   parvec = fill(-1, N)
   parvec[seed] = 0

   Q = copy(seed)
   sizehint!(Q, N)

   u = 0

   while !isempty(Q)
      u = shift!(Q)
      for v in fadj(g, u)
         parvec[v] != -1 && continue
         parvec[v] = u
         push!(Q, v)
      end
   end

   parvec
end

bfs(g::Graph, seed::AbstractVector) = bfs(g, collect(seed))
bfs(g::Graph, seed::Int) = bfs(g, Int[seed])

function bfs_subgraph(g::Graph, seed)
   parvec = bfs(g, seed)
   vlist = find(x->x>0, parvec)
   elist = EdgeID[parvec[v] => v for v in vlist]
   subgraph(g, elist)
end

function dfs(g::Graph, root)
   N = nv(g)

   parvec = fill(-1, N)
   parvec[root] = 0

   order = fill(-1, N)

   S = Int[root]
   sizehint!(S, N)

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

function dfs_subgraph(g::Graph, root)
   parvec, = dfs(g, root)
   vlist = find(x->x>0, parvec)
   elist = EdgeID[parvec[v] => v for v in vlist]
   subgraph(g, elist)
end

################################################# CONNECTIVITY ########################################################

if CAN_USE_LG
   is_connected(g::Graph{LightGraphsAM}) = LightGraphs.is_connected(data(adjmod(g)))
   is_strongly_connected(g::Graph{LightGraphsAM}) = LightGraphs.is_strongly_connected(data(adjmod(g)))
   is_weakly_connected(g::Graph{LightGraphsAM})= LightGraphs.is_weakly_connected(data(adjmod(g)))
   strongly_connected_components(g::Graph{LightGraphsAM})= LightGraphs.strongly_connected_components(data(adjmod(g)))
   condensation(g::Graph{LightGraphsAM})= LightGraphsAM(LightGraphs.condensation(data(adjmod(g))))
end

################################################# SHORTEST PATHS ######################################################

if CAN_USE_LG
   a_star(g::Graph{LightGraphsAM}, s::Int64, t::Int64) = LightGraphs.a_star(data(adjmod(g)), s, t)
   a_star(g::Graph{LightGraphsAM}, s::Int64, t::Int64, propname::Symbol) = LightGraphs.a_star(data(adjmod), s, t, EdgePropInterface(g, propname))

   dijkstra_shortest_paths(g::Graph{LightGraphsAM}, s::Int) = LightGraphs.dijkstra_shortest_paths(data(adjmod(g)), s)
   dijkstra_shortest_paths(g::Graph{LightGraphsAM}, s::Int, propname) = LightGraphs.dijkstra_shortest_paths(data(adjmod(g)), s, EdgePropInterface(g, propname))

   bellman_ford_shortest_paths(g::Graph{LightGraphsAM}, s::Int, propname) = LightGraphs.bellman_ford_shortest_paths(data(adjmod(g)), s, EdgePropInterface(g, propname))

   sssp(g::Graph{LightGraphsAM}, s::Int) = dijkstra_shortest_paths(g, s).dists
   sssp(g::Graph{LightGraphsAM}, s::Int, propname) = dijkstra_shortest_paths(g, s, propname).dists
end

################################################# BETWEENNESS CENTRALITY ###############################################

if CAN_USE_LG
   betweenness_centrality(g::Graph{LightGraphsAM}) = LightGraphs.betweenness_centrality(data(adjmod(g)))
   degree_centrality(g::Graph{LightGraphsAM}) = LightGraphs.degree_centrality(data(adjmod(g)))
   indegree_centrality(g::Graph{LightGraphsAM}) = LightGraphs.indegree_centrality(data(adjmod(g)))
   outdegree_centrality(g::Graph{LightGraphsAM}) = LightGraphs.outdegree_centrality(data(adjmod(g)))
   closeness_centrality(g::Graph{LightGraphsAM}) = LightGraphs.closeness_centrality(data(adjmod(g)))
   katz_centrality(g::Graph{LightGraphsAM}) = LightGraphs.katz_centrality(data(adjmod(g)))
   pagerank(g::Graph{LightGraphsAM}) = LightGraphs.pagerank(data(adjmod(g)))
end
