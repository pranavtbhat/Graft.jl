abstract Message

type MessageAggregate
    mlist
end

immutable ActivateMessage <: Message
    target::Int
end

function processMessage(vrange, active, messge::ActivateMessage)
    active[localIndex(vrange, message.target)] = true
end

function push!(ma::MessageAggregate, m::Message)
    push!(ma.mlist,m)
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
