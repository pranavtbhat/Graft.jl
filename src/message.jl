###
# This file contains the basic Message descriptions and functions to create arrays
# for messages. (Internal use only)
###

"""
Abstract Message type. All subtypes should implement process_message. All implementations
of the Message type must contain a `source` and a `dest` field.
"""
abstract Message

"""Get a messages's source process"""
get_source(x::Message) = x.source
"""Get the messages's destination"""
get_dest(x::Message) = x.dest

"""A queue for subtypes of Message"""
typealias MessageQueue Array{Message, 1}

"""A vector of Message Queues"""
typealias MessageQueueList Array{MessageQueue, 1}

"""A matrix of Message Queues"""
typealias MessageQueueGrid Array{MessageQueue, 2}

"""Generates a vector of MessageQueues"""
function generate_mlist(n::Int)
    mlist = Array{MessageQueue, 1}(n)
    for iter in eachindex(mlist)
        mlist[iter] = MessageQueue()
    end
    mlist
end

"""Generates a two dimensional matrix of MessageQueues."""
function generate_mgrid(n::Int,m::Int=n)
    mgrid = Array{MessageQueue, 2}(n,m)
    for iter in eachindex(mgrid)
        mgrid[iter] = MessageQueue()
    end
    mgrid
end

###
# Basic Message Definitions
###
"""Blank Message type for testing"""
type BlankMessage <: Message
    source::Int
    dest::Int
end
BlankMessage(dest::Int) = BlankMessage(myid(), dest)

"""Message informing the master about the number of active vertices"""
type NumActive <:Message
    source::Int
    dest::Int
    num_active::Int
end
NumActive(num_active::Int) = NumActive(myid(), 0, num_active)

"""Retrieve the number of active vertices"""
get_num_active(x::NumActive) = x.num_active
