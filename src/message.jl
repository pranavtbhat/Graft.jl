###
# This file contains the basic Message descriptions and functions to create arrays
# for messages. (Internal use only)
###

"""
Abstract Message type. All subtypes should implement process_message. All implementations
of the Message type must contain a `dest` field.
"""
abstract Message
get_dest(x::Message) = x.dest

"""
Dummy Message type for testing
"""
type BlankMessage <: Message
    dest::Int
end
process_message(x::BlankMessage) = x

# Some typealiases to make life easier
typealias MessageQueue Array{Message, 1}
typealias MessageQueueList Array{MessageQueue, 1}
typealias MessageQueueGrid Array{MessageQueue, 2}

"""
Generates a vector of MessageQueues
"""
function generate_mlist(n::Int)
    mlist = Array{MessageQueue, 1}(n)
    for iter in eachindex(mlist)
        mlist[iter] = MessageQueue()
    end
    mlist
end

"""
Generates a two dimensional matrix of MessageQueues.
"""
function generate_mgrid(n::Int,m::Int=n)
    mgrid = Array{MessageQueue, 2}(n,m)
    for iter in eachindex(mgrid)
        mgrid[iter] = MessageQueue()
    end
    mgrid
end
