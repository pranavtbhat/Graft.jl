function getParentProc(n, v)
    1 + findlast((x)-> x<=v, round(Int, linspace(1, n+1, length(workers())+1)))
end

function getLocalIndex(vrange, v)
    v - start(vrange) + 1
end

function getGlobalVertex(vrange, i)
    i + start(vrange) - 1
end

function getRanges(len, parts)
    starts = len >= parts ?
        round(Int, linspace(1, len+1, parts+1)) :
        [[1:(len+1);], zeros(Int, parts-len);]

    map(UnitRange, starts[1:end-1], starts[2:end] .- 1)
end
