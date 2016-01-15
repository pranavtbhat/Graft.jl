addprocs(2)

using ParallelGraphs
using Base.Test
import ComputeFramework.domain

domain(::Function) = 1
domain(::ParallelGraphs.MessageInterface) = 1

@everywhere function print_visitor(v, adj, mint, mq, data...)
    println("Vertices:", v)
    println("Vertices:", adj)
    println("Vertices:", mint)
    println("Vertices:", mq)
    println("Vertices:", data)
    return v
end

@everywhere type BlankVertex <: ParallelGraphs.Vertex
    label
    active
end

nv = 10
vlist = [BlankVertex(i,true) for i in 1:nv]
gstruct = rand_graph(nv,0.25)

ParallelGraphs.bsp(print_visitor, vlist, gstruct)
