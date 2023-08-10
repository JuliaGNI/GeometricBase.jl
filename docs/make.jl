using GeometricBase
using Documenter

DocMeta.setdocmeta!(GeometricBase, :DocTestSetup, :(using GeometricBase); recursive=true)

makedocs(;
    modules=[GeometricBase],
    authors="Michael Kraus",
    repo="https://github.com/JuliaGNI/GeometricBase.jl/blob/{commit}{path}#{line}",
    sitename="GeometricBase.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaGNI.github.io/GeometricBase.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo   = "github.com/JuliaGNI/GeometricBase.jl",
    devurl = "latest",
    devbranch = "main",
)
