
if VERSION < v"0.5.0-dev"
    using BaseTestNext
else
    using Base.Test
end

using ParallelGraphs


type TestType
   f1::Int
   f2::Float64
   f3::String
   f4::Any
   f5::Char
end

import Base: ==

(==)(x::TestType, y::TestType) = x.f1 == y.f1 && x.f2 == y.f2 && x.f3 == y.f3 && x.f4 == y.f4 && x.f5 == y.f5

###
# DISPLAY HELPERS
###
introduce(x::String) = print_with_color(:magenta, x, join(fill(" ", 100 - length(x))))
tick() = print_with_color(:magenta, " \u2714\n")

###
# TEST FILES
###
include("adjacency.jl")

include("properties.jl")

include("labelling.jl")

include("util.jl")

include("generator.jl")

include("subgraph.jl")

include("query.jl")

include("filter.jl")

include("parse.jl")

include("algorithms.jl")
