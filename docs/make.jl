using Documenter
using Networks

makedocs(;
    modules=[Networks],
    sitename="Networks.jl",
    authors="Sergio Sánchez Ramírez and contributors",
    pages=["Home" => "index.md", "Interfaces" => "interfaces.md", "API" => "api.md"],
    pagesonly=true,
    checkdocs=:exports,
    warnonly=true,
)

deploydocs(; repo="github.com/sanram-org/Networks.jl", target="build", devbranch="main")
