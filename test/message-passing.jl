import BSP: MessageQueue, MessageList, MessageGrid, generate_mlist, generate_mgrid

@test typeof(generate_mlist(1)) == MessageList
@test typeof(generate_mgrid(2)) == MessageGrid
