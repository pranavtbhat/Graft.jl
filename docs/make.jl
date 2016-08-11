using Documenter, Graft

makedocs(
   # Options
   modules=[Graft]
)

custom_deps() = run(`pip install --user pygments mkdocs mkdocs-material`)

deploydocs(
   #options
   deps = custom_deps,
   repo = "github.com/pranavtbhat/Graft.jl.git",
   julia = "0.5"
)
