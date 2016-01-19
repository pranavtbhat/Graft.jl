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
mbox = ParallelGraphs.get_out_mbox(mint, 1, target_proc)
@test typeof(mbox) == ParallelGraphs.MessageBox
@test isa(fetch(mbox), ParallelGraphs.Message)

inbox = ParallelGraphs.get_in_mboxes(mint, target_proc)
@test length(inbox) == num_procs
@test isa(fetch(inbox[1]), ParallelGraphs.Message)

messages = ParallelGraphs.receive_messages!(mint, target_proc)
@test length(messages) == length(ParallelGraphs.get_local_vertices(mint, target_proc))
@test length(messages[1]) == 1
