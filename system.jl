using AtomsBuilder, AtomsBase, Makie, GLMakie, Unitful, Colors, GeometryBasics, LinearAlgebra
using Makie: ray_at_cursor
include("ase_data.jl")
include("viewer.jl")
jmol_colors = return_data("jmol_colors")
covalent_radii = return_data("covalent_radii")

system = bulk(:Cu) * (4,3,2)

view(system)