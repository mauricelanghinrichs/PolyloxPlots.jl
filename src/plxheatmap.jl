
function dfheatmap!(df, valtransform)
    celltypes = propertynames(df)
    celltypes = celltypes[firstindex(celltypes)+1:end]

    # drop empty barcodes for the specified celltypes => skip for now
    # df = df[sum(eachcol(df[:, celltypes])) .> 0.0, :]

    # reorder celltypes / columns by hierarchical clustering
    d = (corkendall(Matrix(df[!, celltypes])) .- 1) ./ (-2)
    hcl = hclust(d, linkage=:single, branchorder=:optimal)
    
    celltypes = celltypes[hcl.order]
    select!(df, vcat(:Barcode, celltypes))

    # reorder barcode rows, first by fate, within fate groups by sum
    fatesdf = [[v > 0.0 for v in row] for row in eachrow(df[:, celltypes])]
    fatesunique = unique(fatesdf)
    sort!(fatesunique, by = x -> (sum(x), x), rev=false)
    allfates = Dict(fatesunique .=> eachindex(fatesunique))

    df[!, :Fate] = [allfates[fate] for fate in fatesdf]
    df[!, :Sum] = sum(eachcol(df[:, celltypes]))

    sort!(df, [:Fate, :Sum], rev=[false, false])
    select!(df, Not(:Fate))
    select!(df, Not(:Sum))
    
    # transform values values given by transform
    df[!, celltypes] .= mapcols!(col -> valtransform.(col), df[!, celltypes])

    df
end

"""
    plxheatmap(df; <keyword arguments>)

Creates a heatmap of barcode clone sizes for all celltypes in the dataframe (second to last column).

Celltypes are reordered based on a hierarchical clustering with Kendall rank correlation. Barcodes are ordered in groups of same fate combinations, and within these groups via the sum of counts over all celltypes.

# Arguments
- `df::DataFrame`: a barcode dataframe, first column (`:Barcode`) contains barcodes, while all further columns contain barcode reads / cell counts of the celltypes.
- `valtransform = x -> x==zero(x) ? -1 : log(x)`: function that transforms barcode read / cell count values (transformed values used for the colorbar).
- `resolution = (200,250)`: figure resolution / size.

# Examples
```julia-repl
julia> using DataFrames, PolyloxPlots;
julia> df = DataFrame(:Barcode => 1:10, 
                        :A => [10,0,0,1,3,5,3,1,2,5],
                        :B => [1,8,4,0,0,0,0,3,2,1],
                        :C => [10,0,1,1,5,5,7,1,0,5])
julia> fig, ax, hm = plxheatmap(df)
julia> fig # display figure
julia> save("plxheatmap.pdf", fig)
```
"""
function plxheatmap(df::DataFrame;
                valtransform = x -> x==zero(x) ? -1 : log(x),
                resolution = (200,250))
    
    df = deepcopy(df)
    checkdf(df)
    
    dfheatmap!(df, valtransform)

    celltypes = propertynames(df)
    celltypes = celltypes[firstindex(celltypes)+1:end]

    fig, ax, hm = heatmap(transpose(Matrix(df[!, celltypes])),
            colormap=:jet,
            figure = (; resolution=resolution, 
                        # fontsize=12, 
                        fonts=(; regular="Helvetica Neue",
                                bold="Helvetica Neue",
                                italic="Helvetica Neue",
                                bold_italic="Helvetica Neue"),
                        ),
            axis = (; xticks=(eachindex(celltypes), String.(celltypes)),
                        xticklabelrotation=pi/2),
            )

    Colorbar(fig[1, 2], hm)

    fig, ax, hm
end