# Introduction


## The Graph Type

The Graph datatype is the core data-structure used in Graft.jl. The Graph datatype has the following fields:

- `nv`     : The number of vertices in the graph.
- `ne`     : The number of edges int he graph.
- `indxs`  : The adjacency matrix for the graph. The SparseMatrixCSC type is used here, both
             as an adjacency matrix and as an index table, that maps edges onto their entries in the
             edge dataframe.
- `vdata`  : A dataframe used to store vertex data. This dataframe is indexed by the internally used
             vertex identifiers.
- `edata`  : An edge dataframe used to store edge data. This dataframe is indexed by indxs datastructure.
- `lmap`   : A label map that maps externally used labels onto the internally used vertex identifiers and vice versa.
