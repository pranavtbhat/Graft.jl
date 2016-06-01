
if VERSION < v"0.5.0-dev"
    using BaseTestNext
else
    using Base.Test
end

using ParallelGraphs

include("interface.jl")