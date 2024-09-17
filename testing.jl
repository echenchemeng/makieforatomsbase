using AtomsBuilder, AtomsBase, GLMakie, Makie, Unitful, Colors, GeometryBasics, LinearAlgebra
using Makie: ray_at_cursor, ray_assisted_pick

include("ase_data.jl")
include("viewer.jl")

jmol_colors = return_data("jmol_colors")
covalent_radii = return_data("covalent_radii")

system = bulk(:Pt) * (4,3,2)

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

information = Observable{Any}(NaN)
selected = Observable{Any}(NaN)

textbox = Label(f[2,1], "$(selected[]) $(information[])", fontsize = 12, tellwidth = false, tellheight = false)

#= selected_scatter = scatter!(ax, [m["pos"][i] for i in selected],
marker= [m["size"][i] for i in selected],
color = [m["colors"][i] for i in selected],
glowcolor=(:blue, 1.0),
glowwidth= 3.0,
) =#


on(events(ax.scene).keyboardbutton) do event
    if event.action == Keyboard.press || event.action == Keyboard.repeat
        if event.key == Keyboard.space
            output = ray_assisted_pick(ax.scene)
            point_idx = findall(i->i==output[3], m["pos"])
            if isempty(point_idx)
                selected[] = NaN
                information[] = "" 
                f.content[2].text[] = "None selected"
                delete!(ax.scene.plots[end])# Make this so it deletes the scatter plot

                return

            else
                selected[] = point_idx[1]
                information[] = (system.particles[selected[]].species, system.particles[selected[]].position.data)

                scatter!(ax, [m["pos"][i] for i in point_idx],
                        marker= [m["size"][i] for i in point_idx],
                        color = [m["colors"][i] for i in point_idx],
                        glowcolor=(:blue, 1.0),
                        glowwidth= 4.0,
                )
                notify(selected)
                notify(information) 
                f.content[2].text[] = "Atom: $(information[])"
            end
        end
    end
end

current_figure()