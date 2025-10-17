
function dfbubble(df, celltypenames, nallfates)
    celltypes = propertynames(df)
    celltypes = celltypes[firstindex(celltypes)+1:end]

    fatesdf = [[v > 0.0 for v in row] for row in eachrow(df[:, celltypes])]

    fatesunique = Vector{Int}[]
    if length(celltypes) ≤ nallfates
        append!(fatesunique, [reverse(digits(i, base=2, pad=length(celltypes))) 
                                for i in 1:2^length(celltypes)-1]
                )
    else
        append!(fatesunique, unique(fatesdf))
    end
    sort!(fatesunique, by = x -> (sum(x), x), rev=false)

    allfates = Dict(fatesunique .=> eachindex(fatesunique))
    allfatesrev = Dict(values(allfates) .=> keys(allfates))

    fatesdfind = [allfates[fate] for fate in fatesdf]

    minfates = minimum(values(allfates))
    maxfates = maximum(values(allfates))

    x = vcat((fill(i, length(minfates:1:maxfates)) for i in eachindex(celltypes))...)
    y = vcat((collect(minfates:1:maxfates) for __ in eachindex(celltypes))...)

    readfraction = zeros(length(x))
    for (i, (xi, yi)) in enumerate(zip(x, y))
        s = sum(df[!, celltypes[xi]])
        readfraction[i] = sum(df[fatesdfind.==yi, celltypes[xi]]) / s
    end

    all(sum(readfraction[x .== i]) ≈ 1.0 for i in eachindex(celltypes)) || error("Unexpected error, read fractions do not normalise")

    x = x[readfraction .> 0.0]
    y = y[readfraction .> 0.0]
    readfraction = readfraction[readfraction .> 0.0]

    celltypesfirststring = String[]
    if isnothing(celltypenames)
        append!(celltypesfirststring, string.(first.(string.(celltypes))))
    else
        append!(celltypesfirststring, celltypenames)
    end

    ynames = [join(celltypesfirststring[Bool.(allfatesrev[i])]) 
                for i in minfates:1:maxfates]

    x, y, readfraction, (minfates:1:maxfates, ynames)
end

"""
    plxbubble(df; <keyword arguments>)

Creates a bubble chart of fate contributions to all individual celltypes in the dataframe (second to last column).

Contributions are computed from the fraction of reads / cell counts that flow into a given celltype, and visualised via markersize and color. 

# Arguments
- `df::DataFrame`: a barcode dataframe, first column (`:Barcode`) contains barcodes, while all further columns contain barcode reads / cell counts of the celltypes.
- `celltypenames = nothing`: short, ideally, single-letter labels for the celltypes on the y axis; if not specified, the first letter of each celltype will be used (default).
- `nallfates::Int = 6`: the maximum number of celltypes for which all fate combinations are computed; for celltype numbers above, only fates existing in the data will be shown.
- `size = (300,450)`: figure size.

# Examples
```julia-repl
julia> using DataFrames, PolyloxPlots;
julia> df = DataFrame(:Barcode => 1:6,
                    :Aaa => [1,0,0,0,1,0],
                    :Bbb => [0,0.5,0.5,0,1,2],
                    :Ccc => [0,0,0,1,1,2])
julia> fig, ax, sc = plxbubble(df)
julia> fig # display figure
julia> save("plxbubble.pdf", fig)
```
"""
function plxbubble(df::DataFrame;
                celltypenames = nothing,
                nallfates::Int = 6,
                size = (300,450))

    df = deepcopy(df)
    checkdf(df)
    
    x, y, readfraction, yticks = dfbubble(df, celltypenames, nallfates)

    celltypes = propertynames(df)
    celltypes = celltypes[firstindex(celltypes)+1:end]

    fig, ax, sc = scatter(x, y, 
                    markersize=sqrt.(readfraction) .* 50,
                    strokewidth=0,
                    color=readfraction,
                    colormap=:cool,
                    colorrange=(0,1),
                    alpha=0.8,
                    figure = (; size=size, 
                                # fontsize=12, 
                                fonts=(; regular="Helvetica Neue",
                                        bold="Helvetica Neue",
                                        italic="Helvetica Neue",
                                        bold_italic="Helvetica Neue"),
                                ),
                    axis = (; xticks=(eachindex(celltypes), String.(celltypes)),
                                xticklabelrotation=pi/2,
                                limits=(minimum(x)-0.4, maximum(x)+0.4,
                                        minimum(y)-0.5, maximum(y)+0.5),
                                yticks=yticks,
                                ))
    Colorbar(fig[1, 2], sc)
    fig, ax, sc
end