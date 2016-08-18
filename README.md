# Graft.jl

| Build|Coverage|License|Documentation|
|------|--------|-------|-------------|
| [![Build Status](https://travis-ci.org/pranavtbhat/Graft.jl.svg?branch=master)](https://travis-ci.org/pranavtbhat/Graft.jl)| [![codecov.io](http://codecov.io/github/pranavtbhat/Graft.jl/coverage.svg?branch=master)](http://codecov.io/github/pranavtbhat/Graft.jl)|[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/pranavtbhat/Graft.jl/master/LICENSE.md) | [![](https://img.shields.io/badge/docs-stable-blue.svg)](https://pranavtbhat.github.io/Graft.jl/stable) [![](https://img.shields.io/badge/docs-latest-blue.svg)](https://pranavtbhat.github.io/Graft.jl/latest)

A graph toolkit for Julia.

Graft stores vertex and edge metadata in separate dataframes. Adjacencies are stored in a sparsematrix, which also indexes into the edge dataframe. Vertex labels are supported for all external queries, using a bidirectional map. Vertex labels may be of any Julia type.

Data manipulation and analysis in Graft is accomplished with a pipelined query macro system adopted from Jplyr. User queries are parsed recursively, to build a DAG. The DAG is then executed from the bottom up. Results from the execution of intermediate nodes or table data-retrievals are cached to avoid redundant computations.

## Installation
Graft isn't registered yet, so you can clone it directly using:
```julia
julia> Pkg.clone("https://github.com/pranavtbhat/Graft.jl.git")
```

## Examples
- [Google Plus](https://github.com/pranavtbhat/Graft.jl/blob/master/examples/graphapi.md)

## Acknowledgements
This project is supported by `Google Summer of Code` and mentored by [Viral Shah](https://github.com/ViralBShah) and [Shashi Gowda](https://github.com/shashi).
