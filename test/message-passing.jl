addprocs(2)
using Base.Test
using BSP

test_cases = Pair[
    (5,7) => ([2,3,4,5,6],UnitRange{Int}[0:0, 1:1, 2:2, 3:3, 4:4, 5:5, 0:0, 0:0]),
    (9,3) => ([2,2,2,3,3,3,4,4,4], UnitRange{Int}[0:0, 1:3, 4:6, 7:9]),
    (10,3)=> ([2,2,2,3,3,3,3,4,4,4], UnitRange{Int}[0:0, 1:3, 4:7, 8:10])
]

for tc in test_cases
    @test BSP.get_vdist(tc[1]...) == tc[2][1]
    @test BSP.get_wdist(tc[1]...) == tc[2][2]
end

# Message passing scenario
nv = 100
num_procs = 3

test_vertex = 1
test_vertex_parent = 2
local_range = 0:0

m = BSP.BlankMessage(1)
target_proc = 2

@test BSP.mint_init(nv) == nothing
@test length(BSP._mint.dmgrid.refs) == num_procs
@test BSP.getParent(test_vertex) == test_vertex_parent
@test BSP.getLocal() == local_range

@test BSP.sendMessage(m) == nothing
mlist = BSP.getMessageQueueList()
@test typeof(mlist) == BSP.MessageQueueGrid
@test length(mlist[target_proc]) == 1
@test BSP.setMessageQueueList(mlist) == nothing

@test BSP.transmit() == nothing
@test length(BSP._mint.dmgrid.refs) == num_procs

messages = BSP.receive_messages(target_proc)
@test length(messages) == length(BSP.getLocal(target_proc))
@test length(messages[1]) == 1
