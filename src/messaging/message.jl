###
# ABSTRACT MESSAGE TYPE.
###
"""
Abstract Message type. Each message must have a destination vertex and a value.
"""
abstract Message

"""Get the messages's destination"""
get_dest(x::Message) = x.dest
"""Get the messages's value"""
get_val(x::Message) = x.value

"""A group of messages"""
typealias Batch Vector{Message}


###
# MESSAGE SUBTYPES
###
"""Data Message, passed from worker to worker or master to worker"""
abstract DataMessage <: Message

"""Control Message, passed from master to worker or worker to master"""
abstract ControlMessage <: Message
