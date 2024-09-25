using AtomsBuilder, AtomsBase, GLMakie

include("viewer.jl")

system = bulk(:Cu) * (4,3,2)

view(system)