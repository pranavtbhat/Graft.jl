abstract Message

type MessageAggregate
    mlist
end

immutable ActivateMessage <: Message
    target::Int
end


### Auxillary function ###
function processMessage(vrange, active, message::ActivateMessage)
    active[getLocalIndex(vrange, message.target)] = true
end

function push!(ma::MessageAggregate, m::Message)
    push!(ma.mlist,m)
end

function getMessages(ma::MessageAggregate)
    ma.mlist
end

function empty!(ma::MessageAggregate)
    empty!(ma.mlist)
end
# Need to fix this
function generateMQ(n)
    MQ = Array{MessageAggregate,2}(n,n)
    for i in 1:n
        for j in 1:n
            MQ[i,j] = MessageAggregate([])
        end
    end
    MQ
end
