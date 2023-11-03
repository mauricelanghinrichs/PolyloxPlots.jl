
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
    df[!, :Fate] = [[v > 0.0 for v in row] for row in eachrow(df[:, celltypes])]
    df[!, :Sum] = sum(eachcol(df[:, celltypes]))

    sort!(df, [:Fate, :Sum], rev=[false, false])
    select!(df, Not(:Fate, :Sum))
    
    # transform values values given by transform
    df[!, celltypes] .= mapcols!(col -> valtransform.(col), df[!, celltypes])

    df
end

"""
    plxheatmap(prior, dist!, ϵ_target, varexternal; <keyword arguments>)

Run ABC with diffential evolution (de) moves in a Sequential Monte Carlo setup (smc) 
providing posterior samples and a model evidence estimate.

# Arguments
- `prior`: `Distribution` or `Factored` object specifying the parameter prior.
- `nparticles::Int=100`: number of total particles to use for inference.

# Examples
```julia-repl
julia> using ABCdeZ, Distributions;
julia> data = 5;
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