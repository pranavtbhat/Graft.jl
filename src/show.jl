import Base.show

function show(io::IO, x::Vertex)
    write(io, show(get_label(x)))
end

function show(io::IO, x::BlankMessage)
    write(io, "B$(get_dest(x))")
end

function show(io::IO, x::MessageQueue)
    write(io, "MQ[")
    for m in x
        show(io, m)
        write(io, ", ")
    end
    write(io, "]")
end

function show(io::IO, x::MessageQueueList)
    write(io, "MQL[")
    for mq in x
        show(io, mq)
        write(", ")
    end
    write(io, "]")
end

function show(io::IO, x::MessageQueueGrid)
    for mql in x
        show(io, mql)
        write("\n")
    end
end
