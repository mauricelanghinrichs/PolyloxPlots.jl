
function plxheatmap(df::DataFrame;
                resolution=(200,600))
    
    checkdf(df)

    fig, ax, hm = heatmap(randn(20, 20),
            figure = (; resolution=resolution),
            axis = (; title=nothing, xlabel=nothing, ylabel=nothing)
            )

    Colorbar(fig[1, 2], hm, colormap=:jet)

    fig, ax, hm
end