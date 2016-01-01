addprocs(2)
using Base.Test
using BSP

@test BSP.get_vdist(5,7) == [2,3,4,5,6]
@test BSP.get_vdist(9,3) == [2,2,2,3,3,3,4,4,4]
@test BSP.get_vdist(10,3) == [2,2,2,3,3,3,3,4,4,4]

@test BSP.get_wdist(5,7) == UnitRange{Int}[0:0, 1:1, 2:2, 3:3, 4:4, 5:5, 0:0, 0:0]
@test BSP.get_wdist(9,3) == UnitRange{Int}[0:0, 1:3, 4:6, 7:9]
@test BSP.get_wdist(10,3) == UnitRange{Int}[0:0, 1:3, 4:7, 8:10]

@test BSP.mint_init(100) == nothing
@test length(BSP._mint.dmgrid.refs) == 3
@test BSP.getParent(1) == 2
@test BSP.getParent(100) == 3
@test BSP.getLocal() == 0:0

@test BSP.sendMessage(BSP.BlankMessage(1)) == nothing
mlist = BSP.getMessageQueueList()
@test typeof(mlist) == BSP.MessageQueueGrid
@test length(mlist[2]) == 1
@test BSP.setMessageQueueList(mlist) == nothing

@test BSP.transmit() == nothing
@test length(BSP._mint.dmgrid.refs) == 3

mlist = BSP.getMessageQueueList(2)
@test length(mlist[1]) == 1
BSP.setMessageQueueList(mlist, 2)

messages = BSP.receive_messages(2)
@test length(messages) == length(getLocal(2))
@test length(messages[1]) == 1
