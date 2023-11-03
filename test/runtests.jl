
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

@testset "Bubble chart" begin
    df = DataFrame(:Barcode => 1:6,
                :Aaa => [1,0,0,0,1,0],
                :Bbb => [0,0.5,0.5,0,1,2],
                :Ccc => [0,0,0,1,1,2])

    @test plxbubble(df) isa Any
    # @test_nowarn plxheatmap(df)

    celltypenames = nothing
    nallfates = 3
    x, y, readfraction, yticks = PolyloxPlots.dfbubble(df, celltypenames, nallfates)
    @test x == [1, 1, 2, 2, 2, 3, 3, 3]
    @test y == [3, 7, 2, 4, 7, 1, 4, 7]
    @test readfraction == [0.5, 0.5, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25]
    @test yticks == (1:1:7, ["C", "B", "A", "BC", "AC", "AB", "ABC"])

    celltypenames = ["a", "b", "c"]
    nallfates = 3
    x, y, readfraction, yticks = PolyloxPlots.dfbubble(df, celltypenames, nallfates)
    @test x == [1, 1, 2, 2, 2, 3, 3, 3]
    @test y == [3, 7, 2, 4, 7, 1, 4, 7]
    @test readfraction == [0.5, 0.5, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25]
    @test yticks == (1:1:7, ["c", "b", "a", "bc", "ac", "ab", "abc"])

    celltypenames = ["a", "b", "c"]
    nallfates = 2
    x, y, readfraction, yticks = PolyloxPlots.dfbubble(df, celltypenames, nallfates)
    @test x == [1, 1, 2, 2, 2, 3, 3, 3]
    @test y == [3, 5, 2, 4, 5, 1, 4, 5]
    @test readfraction == [0.5, 0.5, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25]
    @test yticks == (1:1:5, ["c", "b", "a", "bc", "abc"])
end