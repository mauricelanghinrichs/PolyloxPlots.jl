
using Documenter
using PolyloxPlots

makedocs(
    sitename = "PolyloxPlots.jl",
    modules = [PolyloxPlots],
    authors = "Maurice Langhinrichs <m.langhinrichs@icloud.com>",
    )

deploydocs(
    repo = "github.com/mauricelanghinrichs/PolyloxPlots.jl.git",
    devbranch = "main",
    )