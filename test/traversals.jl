g = cgraph(10)
@test length(find(bfs(g, 1))) == 10
