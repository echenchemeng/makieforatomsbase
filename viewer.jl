using GLMakie, Unitful,Colors, GeometryBasics, LinearAlgebra

include("ase_data.jl")

function view(system)
    pos = []
    colors = []
    size = []
    for i in system.particles
        push!(pos, ustrip(i.position))
        push!(colors, RGB(jmol_colors[i.species.atomic_number]...))
        push!(size, decompose(Point2f, Circle(Point2f(0), covalent_radii[i.species.atomic_number])))
    end
    f = Figure()
    ax = LScene(f[1, 1])
    scatter!(pos,
        marker= [Polygon(i) for i in size],
        color = colors,
        strokewidth = 2,
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

    mouse_x = Observable(0.0)
    mouse_y = Observable(0.0)

    textbox = Box(f[2, 1], tell_height = false, tell_width = false)

    #text!(textbox, "x = $mouse_x, y= $mouse_y")

    current_figure()
end