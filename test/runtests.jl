
if VERSION < v"0.5.0-dev"
    using BaseTestNext
else
    using Base.Test
end

using ParallelGraphs


type TestType
   f1::Int
   f2::Float64
   f3::ASCIIString
   f4::Any
   f5::Char
end

import Base: ==

(==)(x::TestType, y::TestType) = x.f1 == y.f1 && x.f2 == y.f2 && x.f3 == y.f3 && x.f4 == y.f4 && x.f5 == y.f5

include("util.jl")

include("adjacency.jl")

include("properties.jl")

include("subgraph.jl")

include("query.jl")

include("filter.jl")

include("algorithms.jl")

include("labelling.jl")
