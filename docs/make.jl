using Documenter, Graft

makedocs(
   # Options
   modules=[Graft]
)

deploydocs(
    repo = "github.com/pranavtbhat/Graft.jl.git"
)
