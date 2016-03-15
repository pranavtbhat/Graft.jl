# Test fetchrefs
for pid_1 in procs()
    for pid_2 in procs()
        @test isa(remotecall_fetch(fetchrefs, pid_2, pid_1), Endpoint)
    end
end

# Test register
@test register() == nothing
for pid in procs()
    @test pid in keys(out_refs)
end

# Test minitialize
@test minitialize() == nothing
for pid in procs()
    rdout_refs = remotecall_fetch(()-> ParallelGraphs.out_refs, pid)
    rcout_refs = remotecall_fetch(()-> ParallelGraphs.out_refs, pid)
    for pid in procs()
        @test pid in keys(rdout_refs)
        @test pid in keys(rcout_refs)
    end
end

# Test cachepayload
vp = DebugPayload(0,0)
for pid in procs()
    @test cachepayload(vp, pid) == nothing
    @test isa(pop!(vm_caches[pid]), VertexPayload)
end
empty!(vm_caches)

# Test sendmessage
for pid_1 in procs()
    for pid_2 in procs()
        vm = VertexMessage(pid_2, Vector{VertexPayload}())
        @test remotecall_fetch(sendmessage, pid_1, vm) == nothing
        @test isa(remotecall_fetch(()->take!(ParallelGraphs.in_refs[pid_1]), pid_2), VertexMessage)
    end
end

# Test syncmessages
map(cachepayload, map(x->DebugPayload(0,0), procs()), procs())
@test syncmessages() == nothing
for pid in procs()
    @test isa(remotecall_fetch(()->take!(ParallelGraphs.in_refs[1]), pid), VertexMessage)
end

# Test receivemessages
target_proc = 1
vm = VertexMessage(target_proc, Vector{VertexPayload}())
for pid in procs()
    remotecall_fetch(sendmessage, pid, vm)
end
@test receivemessages() == nothing
@test length(in_queue) == length(procs())
