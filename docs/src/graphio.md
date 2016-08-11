# Graph IO

Graft will eventually support several file formats for reading and writing graphs.
However currently, only a GraphCSV supported. The format is described below

```xml
The input file should contain data in the following format:
<num_vertices>,<num_edges>,<label_type>(1)
<vprop1>,<vprop2>,<vprop3>... (2)
<vproptype1>,<vproptype2>,<vproptype3>... (3)
<eprop1>,<eprop2>,<eprop3>... (4)
<eproptype1>,<eproptype2>,<eproptype3>... (5)
<vertex_label>,<val_1>,<val_2>,<val_3> ... (6)
.
.
.
<vertex_label>,<val_1>,<val_2>,<val_3> ... (Nv + 5)
<from_vertex_label>,<to_vertex_label>,<val_1>,<val_2> ... (Nv + 6)
.
.
.
<from_vertex_label>,<to_vertex_label>,<val_1>,<val_2> ... (Nv + Ne + 5)
EOF
```

```julia
g = loadgraph("graph.txt")

storegraph(g, "graph.txt")
```

Detailed documentation:
```@docs
loadgraph
storegraph
```
