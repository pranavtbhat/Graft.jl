abstract Message

type MessageAggregate
    mset::Set{Any}
end

immutable ActivateMessage <: Message
    target::Int
    data::Int
end

### Auxillary function ###
function push!(ma::MessageAggregate, m::Message)
    union!(ma.mset,[m])
end

function getMessages(ma::MessageAggregate)
    ma.mset
end

function empty!(ma::MessageAggregate)
    empty!(ma.mset)
end
# Need to fix this
function generateMQ(n)
    MQ = Array{MessageAggregate,2}(n,n)
    for i in 1:n
        for j in 1:n
            MQ[i,j] = MessageAggregate(Set{Any}())
        end
    end
    MQ
end
