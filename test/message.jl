@test typeof(BSP.generate_mlist(1)) == BSP.MessageQueueList
@test typeof(BSP.generate_mgrid(2)) == BSP.MessageQueueGrid

# Type compatibility test
mq = BSP.MessageQueue()
push!(mq, BSP.BlankMessage(1))
