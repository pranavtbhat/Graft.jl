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
# MESSAGE AGGREGATIONS
###
"""A group of data messages"""
typealias Batch{T} Vector{T}

"""
A RemoteChannel that functions as a data message buffer.
"""
typealias Endpoint RemoteChannel{Channel{Message}}
