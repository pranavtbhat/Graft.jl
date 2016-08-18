using ProgressMeter

# directories
examples_dir = joinpath(Pkg.dir("Graft"), "examples/")
dataset_dir = joinpath(examples_dir, "gplus")

vertex_file = joinpath(examples_dir, "vertex_data.txt")
edge_file = joinpath(examples_dir, "gplus_combined.txt")

# Change dir if required
if pwd() != examples_dir
   cd(examples_dir)
end

# Download and uncompress the full dataset
if !isdir(dataset_dir)
   download("http://snap.stanford.edu/data/gplus.tar.gz", joinpath(examples_dir, "gplus.tar.gz"))
   run(`tar xzvf gplus.tar.gz`)
end

# Download and uncompress the edge list
if !isfile(edge_file)
   download("http://snap.stanford.edu/data/gplus_combined.txt.gz", joinpath(examples_dir, "gplus_combined.txt.gz"))
   run(`gzip -d gplus_combined.txt.gz`)
end

# List of all ego nodes in dataset
nodes = unique(map(x->split(x, '.')[1], readdir(dataset_dir)))

# Outfile
out = open("vertex_data.txt", "w")

# Function to extract linenums and linevals from *.featnames
function extract_featnames(node)
   N = countlines("$(dataset_dir)/$(node).featnames")
   open("$(dataset_dir)/$(node).featnames", "r") do featnames

      prop_map = Dict(
         "gender" => 1,
         "institution" => 2,
         "job_title" => 3,
         "last_name" => 4,
         "place" => 5,
         "university" => 6
      )


      linenums = sizehint!(Int[], N)
      linevals = sizehint!(String[], N)

      for line in eachline(featnames)
         prop, value = match(r"\d+\s([\w_]+):(.*)", rstrip(line)).captures
         push!(linenums, prop_map[prop])
         push!(linevals, join(value))
      end

      linenums, linevals
   end
end

# Iterate over nodes and build the vertex dataset
p = Progress(length(nodes), 1)
for (count,node) in enumerate(nodes)
   # Fetch the data compression scheme
   linenums, linevals = extract_featnames(node)

   # Compute the size of the data array stored in the file
   M = countlines("$(dataset_dir)/$(node).feat")
   N = length(linenums)

   # Initialize data arrays
   labels = sizehint!(Int128[], N+1)
   genders = sizehint!(Int[], N+1)
   institutions = sizehint!(Vector{String}[], N+1)
   job_titles = sizehint!(Vector{String}[], N+1)
   last_names = sizehint!(String[], N+1)
   places = sizehint!(Vector{String}[], N+1)
   universities = sizehint!(Vector{String}[], N+1)

   # Extract alter-ego data
   feats = readdlm("$(dataset_dir)/$(node).feat", Int128, dims=(M,N+1))

   for i in 1 : size(feats, 1)
      push!(labels, feats[i,1])

      arr = feats[i,2:end]
      props = linenums .* arr

      gs = filter(x->length(x) > 0, linevals[find(x-> x == 1, props)])
      push!(genders, length(gs) == 0 ? 0 : parse(gs[1]))
      push!(institutions, filter(x->length(x) > 0, linevals[find(x-> x == 2, props)]))
      push!(job_titles, filter(x->length(x) > 0, linevals[find(x-> x == 3, props)]))
      push!(last_names, join(linevals[find(x-> x == 4, props)], ' '))
      push!(places, filter(x->length(x) > 0, linevals[find(x-> x == 5, props)]))
      push!(universities, filter(x->length(x) > 0, linevals[find(x-> x == 6, props)]))
   end

   # Extract ego-node data
   feats = map(parse, split(readline(open("$(dataset_dir)/$(node).egofeat"))))
   props = linenums .* feats

   push!(labels, parse(Int128, node))

   gs = filter(x->length(x) > 0, linevals[find(x-> x == 1, props)])
   push!(genders, length(gs) == 0 ? 0 : parse(gs[1]))
   push!(institutions, filter(x->length(x) > 0, linevals[find(x-> x == 2, props)]))
   push!(job_titles, filter(x->length(x) > 0, linevals[find(x-> x == 3, props)]))
   push!(last_names, join(linevals[find(x-> x == 4, props)], ' '))
   push!(places, filter(x->length(x) > 0, linevals[find(x-> x == 5, props)]))
   push!(universities, filter(x->length(x) > 0, linevals[find(x-> x == 6, props)]))

   # Join data arrays and write to file+
   vdata = hcat(labels, genders, institutions, job_titles, last_names, places, universities)
   writedlm(out, vdata)

   update!(p, count)
end

# flush buffer
close(out)

# Write the header
open("Graph.txt", "w") do gfile
   println(gfile, "107614\t13673453\tInt128")
   println(gfile, join(["gender", "institution", "job_title", "last_name", "place", "university"], '\t'))
   println(gfile, join(["Int", "Vector{String}", "Vector{String}", "String", "Vector{String}", "Vector{String}"], '\t'))
   println(gfile)
   println(gfile)
end
