"""
Abstract Message type. All subtypes should implement process_message.
"""
abstract Message
process_message(::Message, ::AuxStruct) = error("No process method defined for this type")

# Some typealiases to make life easier
typealias MessageQueue Array{Message, 1}
typealias MessageList Array{MessageQueue, 1}
typealias MessageGrid Array{MessageQueue, 2}

"""
Generates a two dimensional matrix of MessageQueues.
"""
function generate_mlist(n::Int)
    mlist = Array{MessageQueue, 1}(n)
    for iter in eachindex(mlist)
        mlist[iter] = MessageQueue()
    end
    mlist
end

"""
Generates a vector of MessageQueues
"""
function generate_mgrid(n::Int)
    mgrid = Array{MessageQueue, 2}(n,n)
    for iter in eachindex(mgrid)
        mgrid[iter] = MessageQueue()
    end
    mgrid
end


"""
Send a message to vertex v
"""
