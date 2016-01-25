@everywhere function test_visitor(v, adj, mint, mq, data...)
    v::Vertex
    adj::Vector
    mint::MessageInterface
    mq::MessageAggregate
    data::Tuple

    # Randomly deactivate
    rand_num = rand()
    if rand_num < 0.2
        v.label = rand_num
        ParallelGraphs.deactivate!(v)
    end
    return v
end

@everywhere type TestVertex <: ParallelGraphs.Vertex
    label
    active
end

nv = 10
vlist = [TestVertex(i,true) for i in 1:nv]
gstruct = rand_graph(nv,0.25)

vlist = ParallelGraphs.bsp(test_visitor, vlist, gstruct).xs
vlist = reduce(vcat, [], vlist)
for v in vlist
    @test get_label(v) < 0.2 && !ParallelGraphs.is_active(v)
end
