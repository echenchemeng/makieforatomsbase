function position_from_selected(idx)

    if typeof(idx) == Vector{Int}
        return [m["pos"][i] for i in idx]
    else
        return []
    end

end

function marker_from_selected(idx)

    if typeof(idx) == Vector{Int}
        return [m["size"][i] for i in idx]
    else
        return []
    end

end

function color_from_selected(idx)

    if typeof(idx) == Vector{Int}
        return [m["colors"][i] for i in idx]
    else
        return []
    end

end