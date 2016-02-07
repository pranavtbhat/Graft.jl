import Base.show

# function show(io::IO, x::BlankMessage)
#     write(io, "B$(get_source(x))->$(getdest(x))")
# end
#
# function show(io::IO, x::MessageAggregate)
#     write(io, "MQ[")
#     for m in x
#         show(io, m)
#         write(io, ", ")
#     end
#     write(io, "]")
# end
#
# function show(io::IO, x::MessageAggregateList)
#     write(io, "MQL[")
#     for mq in x
#         show(io, mq)
#         write(", ")
#     end
#     write(io, "]")
# end
#
# function show(io::IO, x::MessageAggregateGrid)
#     for mql in x
#         show(io, mql)
#         write("\n")
#     end
# end
