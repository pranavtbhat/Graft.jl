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

"""Error message containing an exception from a worker process"""
type ErrorMessage <: Message
    source::Int
    dest::Int
    err::Exception
    v::Vertex
end
ErrorMessage(x::Exception, v::Vertex) = ErrorMessage(myid(), 0, x, v)

"""Retrieve the error from an ErrorMessage"""
get_error(x::ErrorMessage) = x.err

"""Retrieve the problematic vertex"""
get_vertex(x::ErrorMessage) = x.v
