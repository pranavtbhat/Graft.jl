# Message passing scenario
nv = 100
num_procs = 3

test_vertex = 1
test_vertex_parent = 2
local_range = 0:0

m = ParallelGraphs.BlankMessage(1)
target_proc = 2

metadata = UnitRange{Int}[1:50, 50:100]

mint = ParallelGraphs.message_interface(metadata)
@test typeof(mint) == ParallelGraphs.MessageInterface

@test ParallelGraphs.get_parent(mint, test_vertex) == test_vertex_parent
@test ParallelGraphs.get_local_vertices(mint) == local_range

@test ParallelGraphs.send_message!(mint, m) == nothing
@test ParallelGraphs.transmit!(mint) == nothing

mbox = mint.mgrid[1,target_proc]
@test typeof(mbox) == ParallelGraphs.MessageBox
ma = fetch(mbox)
@test isa(ma, ParallelGraphs.MessageAggregate)
@test length(ma) == 1

inbox = mint.mgrid[:,target_proc]
@test length(inbox) == num_procs
ma = fetch(inbox[1])
@test isa(ma, ParallelGraphs.MessageAggregate)
@test length(ma) == 1

messages = ParallelGraphs.receive_messages!(mint, target_proc)
@test length(messages) == length(ParallelGraphs.get_local_vertices(mint, target_proc))
@test length(messages[1]) == 1
