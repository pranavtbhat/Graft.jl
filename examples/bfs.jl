addprocs(2)

using BSP

@everywhere function visitorFunction(v, vrange, active, graph, MQ, data)
    println(v)
end

m = sparse(ones(Int,10,10))
node = bsp(1, m)
compute(Context(), node)
