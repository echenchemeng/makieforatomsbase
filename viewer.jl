using GLMakie, Unitful,Colors, GeometryBasics, LinearAlgebra

include("ase_data.jl")
include("observable_assign_functions.jl")

function view(system)
    m = Dict(
        "pos" => [],
        "colors" => [],
        "size" => [],
        "outline" => [],
        )

    for i in system.particles
        push!(m["pos"], ustrip(i.position))
        push!(m["colors"], RGB(jmol_colors[i.species.atomic_number]...))
        push!(m["size"], decompose(Point2f, Circle(Point2f(0), covalent_radii[i.species.atomic_number])))
    end

    m["outline"] = [ count*0.1 for (count, _) in enumerate(system.particles)]
    m["size"] = [Polygon(i) for i in m["size"]]
    f = Figure(size = (600, 600))
    ax = LScene(f[1, 1], height = 500, width = 500)

    scatter!(
        m["pos"],
        marker= m["size"],
        color = m["colors"],
        # strokewidth = m["outline"],
        strokewidth = 2.,
        )


    v1, v2, v3 = [ustrip(i) for i in system.cell.cell_vectors]
    
    vertices = [
    [0, 0, 0],       # Origin
    v1,              # v1
    v2,              # v2
    v3,              # v3
    v1 + v2,         # v1 + v2
    v1 + v3,         # v1 + v3
    v2 + v3,         # v2 + v3
    v1 + v2 + v3     # v1 + v2 + v3
    ]

    # Define the edges as pairs of vertices
    edges = [
        (vertices[1], vertices[2]),
        (vertices[1], vertices[3]),
        (vertices[1], vertices[4]),
        (vertices[2], vertices[5]),
        (vertices[2], vertices[6]),
        (vertices[3], vertices[5]),
        (vertices[3], vertices[7]),
        (vertices[4], vertices[6]),
        (vertices[4], vertices[7]),
        (vertices[5], vertices[8]),
        (vertices[6], vertices[8]),
        (vertices[7], vertices[8])
    ]

    for i in edges
        linesegments!([i[1][1], i[2][1]], 
                    [i[1][2], i[2][2]], 
                    [i[1][3], i[2][3]], 
                    color=RGBA(0.5,0.5,0.5,0.5),
                    linestyle=:dot)
    end

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


    information = Observable{Any}("None selected")
    selected = Observable{Any}(NaN)
    positions = Observable{Any}(NaN)
    positions = lift(position_from_selected, selected)
    markers = lift(marker_from_selected, selected)
    colors = lift(color_from_selected, selected)

    textbox = Label(f[2,1], "$(information[])", fontsize = 12, tellwidth = false, tellheight = false)

    on(events(ax.scene).keyboardbutton) do event
        if event.action == Keyboard.press || event.action == Keyboard.repeat
            if event.key == Keyboard.space
                output = ray_assisted_pick(ax.scene)
                point_idx = findall(i->i==output[3], m["pos"])

                if isempty(point_idx)

                    while typeof(ax.scene.plots[end])<:Scatter
                        delete!(ax.scene,ax.scene.plots[end])
                    end
                    selected[] = NaN
                    information[] = "" 
                    f.content[2].text[] = "None selected"

                    return

                else

                    if any(isnan,selected[])
                        selected[] = point_idx

                        information[] = ("$(system.particles[selected[][1]].species), $(system.particles[selected[][1]].position.data)")

                        scatter!(ax, 
                                positions,
                                marker= markers,
                                color = colors,
                                glowcolor=(:blue, 1.0),
                                glowwidth= 4.0,
                        )

                        f.content[2].text[] = "Atom: $(information[])"
                    

                    elseif point_idx[1] ∉ selected[]
                        push!(selected[], point_idx[1])
                        notify(selected)
                        information[] = selected[]
                        f.content[2].text[] = "Atom: $(information[])"
                    end
                end
            end
        end
    end

    current_figure()
end