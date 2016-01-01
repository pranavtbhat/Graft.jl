import BSP: MessageQueue, MessageQueueList, MessageQueueGrid, generate_mlist, generate_mgrid
using Base.Test
@test typeof(generate_mlist(1)) == MessageQueueList
@test typeof(generate_mgrid(2)) == MessageQueueGrid

# Type compatibility test
mq = MessageQueue()
push!(mq, BSP.BlankMessage(1))
