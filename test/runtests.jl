using Test
using SafeTestsets

@testset "Unit" verbose = true begin
    @safetestset "Network" include("unit/network.jl")

    # algorithms
    @safetestset "Cycles" include("unit/cycles.jl")
end

@testset "Integration" verbose = true begin
    @safetestset "Graphs" include("integration/graphs.jl")
end
