@test typeof(ParallelGraphs.generate_mlist(1)) == ParallelGraphs.MessageQueueList
@test typeof(ParallelGraphs.generate_mgrid(2)) == ParallelGraphs.MessageQueueGrid

# Type compatibility test
mq = ParallelGraphs.MessageQueue()
push!(mq, ParallelGraphs.BlankMessage(1))
