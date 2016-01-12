test_cases = Pair[
    (5,7) => ([2,3,4,5,6],UnitRange{Int}[0:0, 1:1, 2:2, 3:3, 4:4, 5:5, 0:0, 0:0]),
    (9,3) => ([2,2,2,3,3,3,4,4,4], UnitRange{Int}[0:0, 1:3, 4:6, 7:9]),
    (10,3)=> ([2,2,2,3,3,3,3,4,4,4], UnitRange{Int}[0:0, 1:3, 4:7, 8:10])
]

for tc in test_cases
    @test ParallelGraphs.get_vdist(tc[1]...) == tc[2][1]
    @test ParallelGraphs.get_wdist(tc[1]...) == tc[2][2]
end

# Message passing scenario
nv = 100
num_procs = 3

test_vertex = 1
test_vertex_parent = 2
local_range = 0:0

m = ParallelGraphs.BlankMessage(1)
target_proc = 2

mint = ParallelGraphs.message_interface(nv)
@test typeof(mint) == ParallelGraphs.MessageInterface

@test length(mint.dmgrid.refs) == num_procs
@test ParallelGraphs.get_parent(mint, test_vertex) == test_vertex_parent
@test ParallelGraphs.get_local_vertices(mint) == local_range

@test ParallelGraphs.send_message(mint, m) == nothing
mlist = ParallelGraphs.get_message_queue_list(mint)
@test typeof(mlist) == ParallelGraphs.MessageQueueGrid
@test length(mlist[target_proc]) == 1
@test ParallelGraphs.set_message_queue_list(mint, mlist) == nothing

@test ParallelGraphs.transmit(mint) == nothing
@test length(mint.dmgrid.refs) == num_procs

messages = ParallelGraphs.receive_messages(mint, target_proc)
@test length(messages) == length(ParallelGraphs.get_local_vertices(mint, target_proc))
@test length(messages[1]) == 1
