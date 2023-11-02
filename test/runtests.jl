
using PolyloxPlots
using Random
using Test

Random.seed!(1)

@testset "Heatmap" begin
    d = 5
    @test all((0, 100) .<= d .<= (1, 101))

end