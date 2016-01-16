gstruct = rand_graph(10, 0.2)
to_list(gstruct)

@test length(connected_components(gstruct)) == nv
