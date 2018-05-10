# To allow not having installed the package
push!(LOAD_PATH, "../src/")

using Documenter, Tick



# To generate site with mkdocs (see make.jl config):
# pip install mkdocs python-markdown-math
# mkdocs serve

# makedocs() # then generate site with mkdocs




makedocs(
    modules = [Tick],
    format = :html,
    sitename = "Tick.jl",
    authors = "Ludovic Coquelle",
    clean = true,
    pages = Any[
        "Index"=>"index.md",
        "Tutorial"=>"tutorial.md",
        "Reference"=>"reference.md",
    ]
)
