import Base.show

function show(io::IO, x::MessageAggregate)
    write(io, "[")
    for msg in x.mlist
        show(io, msg)
        write(io,", ")
    end
    write(io, "]")
end

function show(io::IO, x::AbstractArray{MessageAggregate, 1})
    write(io,"[")
    for ma in x
        show(io, ma)
    end
    write(io,"]")
end

function show(io::IO, x::AbstractArray{MessageAggregate, 2})
    for i in 1:size(x)[2]
        show(io, x[:,i])
    end
end

function show(io::IO, x::ActivateMessage)
    write(io, "a")
    show(io, x.target)
end
