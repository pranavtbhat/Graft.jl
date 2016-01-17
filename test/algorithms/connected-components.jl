gstruct = Vector{Int}[[2,3], [1,4], [1,4], [2,3], [6,7], [5,7], [5,6], [9,10], [8,10], [8,9,11], [10], [13], [12]]
gstruct::ParallelGraphs.AdjacencyList
@test connected_components(gstruct) == [1,1,1,1,5,5,5,8,8,8,8,12,12]
