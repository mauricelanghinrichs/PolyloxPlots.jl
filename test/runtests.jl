
using PolyloxPlots
using DataFrames
using Test

@testset "Heatmap" begin
    df = DataFrame(:Barcode => 1:10,
                :A => [10,0,0,1,3,5,3,1,2,5],
                :B => [1,8,4,0,0,0,0,3,2,1],
                :C => [10,0,1,1,5,5,7,1,0,5])

    @test plxheatmap(df) isa Any
    # @test_nowarn plxheatmap(df)

    dfres = deepcopy(df)
    PolyloxPlots.dfheatmap!(dfres, x -> x)

    # show(df, allrows=true)
    # show(dfres, allrows=true)

    sortinds = sortperm(dfres.Barcode)
    @test propertynames(df) == [:Barcode, :A, :B, :C]
    @test propertynames(dfres) == [:Barcode, :A, :C, :B]
    @test df.Barcode == 1:10
    @test dfres.Barcode == [2, 3, 9, 4, 5, 6, 7, 8, 10, 1]
    @test df.Barcode == dfres.Barcode[sortinds]
    @test df.A == dfres.A[sortinds]
    @test df.B == dfres.B[sortinds]
    @test df.C == dfres.C[sortinds]

    dfres = deepcopy(df)
    PolyloxPlots.dfheatmap!(dfres, x -> x==zero(x) ? -1 : log(x))

    # show(df, allrows=true)
    # show(dfres, allrows=true)

    @test propertynames(df) == [:Barcode, :A, :B, :C]
    @test propertynames(dfres) == [:Barcode, :A, :C, :B]
    @test df.Barcode == 1:10
    @test dfres.Barcode == [2, 3, 9, 4, 5, 6, 7, 8, 10, 1]
    
    sortinds = sortperm(dfres.Barcode)
    @test all(dfres.A[sortinds][df.A .== 0] .== -1)
    @test all(dfres.B[sortinds][df.B .== 0] .== -1)
    @test all(dfres.C[sortinds][df.C .== 0] .== -1)

    @test all(dfres.A[sortinds][df.A .!= 0] .≈ log.(df.A[df.A .!= 0]))
    @test all(dfres.B[sortinds][df.B .!= 0] .≈ log.(df.B[df.B .!= 0]))
    @test all(dfres.C[sortinds][df.C .!= 0] .≈ log.(df.C[df.C .!= 0]))
end