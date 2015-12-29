### ComputeNode for Bulk Syncrhonous Parallel processing ###
immutable BSPNode <: ComputeNode
    f::Function
    seed::Int
    graph::Any
end
bsp(f,seed,graph) = BSPNode(f,seed,graph)
