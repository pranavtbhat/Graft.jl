# Type compatibility test
mq = ParallelGraphs.MessageQueue()
push!(mq, ParallelGraphs.BlankMessage(1))
