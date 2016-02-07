###
# ABSTRACT MESSAGE TYPE.
###
"""
Abstract Message type. Each message must have a destination process and a value.
"""
abstract Message

"""Get the messages's destination"""
getdest(x::Message) = x.dest
"""Get the messages's value"""
getval(x::Message) = x.value

###
# MESSAGE SUBTYPES
###
"""Data Message, passed from worker to worker or master to worker"""
abstract DataMessage <: Message

"""Control Message, passed from master to worker or worker to master"""
abstract ControlMessage <: Message

###
# AGGREGATIONS
###
"""A group of data messages"""
typealias Batch{T<:Message} Vector{T<:Message}

###
# CHANNEL ALIASES
###
"""A RemoteChannel that functions as a control message buffer"""
typealias ControlEndpoint RemoteChannel{Channel{ControlMessage}}

"""
A RemoteChannel that functions as a data message buffer. Can recieve messages
in piecemeal or in bulk.
"""
typealias DataEndpoint RemoteChannel{Channel{DataMessage}}
