
<a id='ParallelGraphs-Documentation-1'></a>

# ParallelGraphs Documentation

- [ParallelGraphs Documentation](index.md#ParallelGraphs-Documentation-1)
    - [Type Aliases](index.md#Type-Aliases-1)
    - [The Graph datastructure](index.md#The-Graph-datastructure-1)
    - [EdgeIteration](index.md#EdgeIteration-1)
    - [Metadata](index.md#Metadata-1)
    - [Queries](index.md#Queries-1)


<a id='Type-Aliases-1'></a>

## Type Aliases

<a id='ParallelGraphs.VertexID' href='#ParallelGraphs.VertexID'>#</a>
**`ParallelGraphs.VertexID`** &mdash; *Type*.



Datatype used to store vertex id numbers 

<strong>Methods</strong>

This function has no methods to display.

_Hiding 1 method defined outside of this package._

<a id='ParallelGraphs.EdgeID' href='#ParallelGraphs.EdgeID'>#</a>
**`ParallelGraphs.EdgeID`** &mdash; *Type*.



Datatype used to store edges 

<strong>Methods</strong>

This function has no methods to display.

_Hiding 2 methods defined outside of this package._

<a id='ParallelGraphs.VertexList' href='#ParallelGraphs.VertexList'>#</a>
**`ParallelGraphs.VertexList`** &mdash; *Type*.



A list of Vertex IDs 

<a id='ParallelGraphs.EdgeList' href='#ParallelGraphs.EdgeList'>#</a>
**`ParallelGraphs.EdgeList`** &mdash; *Type*.



A list of Edge IDs 


<!– #################################################################################################################### –>


<a id='The-Graph-datastructure-1'></a>

## The Graph datastructure


The Graph datatype is the core datastructure used in Graft.jl. The Graph datatype has the following fields: 1. nv     : The number of vertices in the graph. 2. ne     : The number of edges int he graph. 3. indxs  : The adjacency matrix for the graph. The SparseMatrixCSC type is used here, both             as an adjacency matrix and as an index table, that maps edges onto their entries in the             edge dataframe. 4. vdata  : A dataframe used to store vertex data. This dataframe is indexed by the internally used             vertex identifiers. 5. edata  : An edge dataframe used to store edge data. This dataframe is indexed by indxs datastructure. 6. lmap   : A label map that maps externally used labels onto the internally used vertex identifiers and vice versa.


<a id='Accessors-1'></a>

### Accessors

<a id='ParallelGraphs.nv' href='#ParallelGraphs.nv'>#</a>
**`ParallelGraphs.nv`** &mdash; *Function*.



The number of vertices in the adjacency matrix 


The number of vertices in the graph 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre class="documenter-inline"><span class="nf">nv</span><span class="p">(</span><span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/graph.jl:39</a>
</li>
<li>
    <pre class="documenter-inline"><span class="nf">nv</span><span class="p">(</span><span class="n">x</span><span class="p">::</span><span class="n">ParallelGraphs.IdentityLM</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/labelmap.jl:55</a>
</li>
<li>
    <pre class="documenter-inline"><span class="nf">nv</span><span class="p">(</span><span class="n">x</span><span class="p">::</span><span class="n">SparseMatrixCSC{Int64,Ti<:Integer}</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/sparsematrix.jl:17</a>
</li>
<li>
    <pre class="documenter-inline"><span class="nf">nv</span><span class="p">(</span><span class="n">x</span><span class="p">::</span><span class="n">ParallelGraphs.DictLM</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/labelmap.jl:86</a>
</li>
</ul>

<a id='ParallelGraphs.ne' href='#ParallelGraphs.ne'>#</a>
**`ParallelGraphs.ne`** &mdash; *Function*.



The number of edges in the adjacency matrix 


The number of edges in the graph 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre class="documenter-inline"><span class="nf">ne</span><span class="p">(</span><span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/graph.jl:42</a>
</li>
<li>
    <pre class="documenter-inline"><span class="nf">ne</span><span class="p">(</span><span class="n">x</span><span class="p">::</span><span class="n">SparseMatrixCSC{Int64,Ti<:Integer}</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/sparsematrix.jl:20</a>
</li>
</ul>

<a id='ParallelGraphs.indxs' href='#ParallelGraphs.indxs'>#</a>
**`ParallelGraphs.indxs`** &mdash; *Function*.



Retrieve the adjacency matrix / edge index table 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre class="documenter-inline"><span class="nf">indxs</span><span class="p">(</span><span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/graph.jl:45</a>
</li>
</ul>

<a id='ParallelGraphs.vdata' href='#ParallelGraphs.vdata'>#</a>
**`ParallelGraphs.vdata`** &mdash; *Function*.



Retrieve the vertex dataframe 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre class="documenter-inline"><span class="nf">vdata</span><span class="p">(</span><span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/graph.jl:48</a>
</li>
</ul>

<a id='ParallelGraphs.edata' href='#ParallelGraphs.edata'>#</a>
**`ParallelGraphs.edata`** &mdash; *Function*.



Retrieve the edge dataframe 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre class="documenter-inline"><span class="nf">edata</span><span class="p">(</span><span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/graph.jl:51</a>
</li>
</ul>

<a id='ParallelGraphs.lmap' href='#ParallelGraphs.lmap'>#</a>
**`ParallelGraphs.lmap`** &mdash; *Function*.



Retrieve the label map 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre class="documenter-inline"><span class="nf">lmap</span><span class="p">(</span><span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/graph.jl:54</a>
</li>
</ul>


<a id='Construction-1'></a>

### Construction


The following methods can be used to construct unlabelled graphs:

<a id='ParallelGraphs.emptygraph' href='#ParallelGraphs.emptygraph'>#</a>
**`ParallelGraphs.emptygraph`** &mdash; *Function*.


<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre class="documenter-inline"><span class="nf">emptygraph</span><span class="p">(</span><span class="n">nv</span><span class="p">::</span><span class="n">Int64</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/generator.jl:51</a>
</li>
</ul>

<a id='ParallelGraphs.randgraph' href='#ParallelGraphs.randgraph'>#</a>
**`ParallelGraphs.randgraph`** &mdash; *Function*.



Returns a small completegraph with properties(for doc examples) 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre><span class="nf">randgraph</span><span class="p">(</span>
    <span class="n">nv</span><span class="p">::</span><span class="n">Int64</span><span class="p">,
</span>    <span class="n">vprops</span><span class="p">::</span><span class="n">Array{Symbol,1}</span><span class="p">,
</span>    <span class="n">eprops</span><span class="p">::</span><span class="n">Array{Symbol,1}</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/generator.jl:60</a>
</li>
<li>
    <pre class="documenter-inline"><span class="nf">randgraph</span><span class="p">(</span><span class="n">nv</span><span class="p">::</span><span class="n">Int64</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/generator.jl:56</a>
</li>
<li>
    <pre class="documenter-inline"><span class="nf">randgraph</span><span class="p">(</span><span class="n">nv</span><span class="p">::</span><span class="n">Int64</span><span class="p">, </span><span class="n">ne</span><span class="p">::</span><span class="n">Int64</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/generator.jl:55</a>
</li>
</ul>

<a id='ParallelGraphs.completegraph' href='#ParallelGraphs.completegraph'>#</a>
**`ParallelGraphs.completegraph`** &mdash; *Function*.


<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre class="documenter-inline"><span class="nf">completegraph</span><span class="p">(</span><span class="n">nv</span><span class="p">::</span><span class="n">Int64</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/generator.jl:80</a>
</li>
</ul>


Labelled graphs can be build using the constructors:

<a id='ParallelGraphs.Graph-Tuple{Int64,Array{T,1}}' href='#ParallelGraphs.Graph-Tuple{Int64,Array{T,1}}'>#</a>
**`ParallelGraphs.Graph`** &mdash; *Method*.


<a id='ParallelGraphs.Graph-Tuple{Int64,Array{T,1},Int64}' href='#ParallelGraphs.Graph-Tuple{Int64,Array{T,1},Int64}'>#</a>
**`ParallelGraphs.Graph`** &mdash; *Method*.



<a id='Combinatorial-stuff-1'></a>

### Combinatorial stuff


Basic methods on graph structure:

<a id='ParallelGraphs.vertices' href='#ParallelGraphs.vertices'>#</a>
**`ParallelGraphs.vertices`** &mdash; *Function*.



The list of the vertices in the graph 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre class="documenter-inline"><span class="nf">vertices</span><span class="p">(</span><span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/combinatorial.jl:16</a>
</li>
</ul>

<a id='ParallelGraphs.edges' href='#ParallelGraphs.edges'>#</a>
**`ParallelGraphs.edges`** &mdash; *Function*.



Returns an edge iterator containing all edges in the graph 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre class="documenter-inline"><span class="nf">edges</span><span class="p">(</span><span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/combinatorial.jl:20</a>
</li>
</ul>

<a id='ParallelGraphs.hasvertex' href='#ParallelGraphs.hasvertex'>#</a>
**`ParallelGraphs.hasvertex`** &mdash; *Function*.



Check if the vertex(s) exists 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre><span class="nf">hasvertex</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">v</span><span class="p">::</span><span class="n">Int64</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/combinatorial.jl:24</a>
</li>
<li>
    <pre><span class="nf">hasvertex</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">vs</span><span class="p">::</span><span class="n">AbstractArray{Int64,1}</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/combinatorial.jl:25</a>
</li>
</ul>

<a id='ParallelGraphs.hasedge' href='#ParallelGraphs.hasedge'>#</a>
**`ParallelGraphs.hasedge`** &mdash; *Function*.



Check if the edge(s) exists 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre><span class="nf">hasedge</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">e</span><span class="p">::</span><span class="n">Pair{Int64,Int64}</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/combinatorial.jl:29</a>
</li>
<li>
    <pre><span class="nf">hasedge</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">es</span><span class="p">::</span><span class="n">AbstractArray{Pair{Int64,Int64},1}</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/combinatorial.jl:30</a>
</li>
</ul>


Adjacency queries:

<a id='ParallelGraphs.fadj' href='#ParallelGraphs.fadj'>#</a>
**`ParallelGraphs.fadj`** &mdash; *Function*.



Retrieve a list of vertices connected to vertex v.

This method spwans a new array, so is slow and malloc prone.


Vertex v's out-neighbors in the graph 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre><span class="nf">fadj</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">v</span><span class="p">::</span><span class="n">Int64</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/combinatorial.jl:35</a>
</li>
<li>
    <pre><span class="nf">fadj</span><span class="p">(</span>
    <span class="n">x</span><span class="p">::</span><span class="n">SparseMatrixCSC{Int64,Ti<:Integer}</span><span class="p">,
</span>    <span class="n">v</span><span class="p">::</span><span class="n">Int64</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/sparsematrix.jl:136</a>
</li>
</ul>

<a id='ParallelGraphs.fadj!' href='#ParallelGraphs.fadj!'>#</a>
**`ParallelGraphs.fadj!`** &mdash; *Function*.



Retrieve a list of vertices connect to vertex v.

This method copies the adjacencies onto the input array, and is comparitively faster, and causes no mallocs.


Retrieve a list of vertices connect to vertex v.

This method copies the adjacencies onto the input array, and is comparitively faster, and causes no mallocs.

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre><span class="nf">fadj!</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">v</span><span class="p">::</span><span class="n">Int64</span><span class="p">,
</span>    <span class="n">adj</span><span class="p">::</span><span class="n">Array{Int64,1}</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/combinatorial.jl:43</a>
</li>
<li>
    <pre><span class="nf">fadj!</span><span class="p">(</span>
    <span class="n">x</span><span class="p">::</span><span class="n">SparseMatrixCSC{Int64,Ti<:Integer}</span><span class="p">,
</span>    <span class="n">v</span><span class="p">::</span><span class="n">Int64</span><span class="p">,
</span>    <span class="n">adj</span><span class="p">::</span><span class="n">Array{Int64,1}</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/sparsematrix.jl:148</a>
</li>
</ul>

<a id='ParallelGraphs.outdegree' href='#ParallelGraphs.outdegree'>#</a>
**`ParallelGraphs.outdegree`** &mdash; *Function*.



Compute the outdegree of a vertex 


Vertex v's outdegree in the graph 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre><span class="nf">outdegree</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">v</span><span class="p">::</span><span class="n">Int64</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/combinatorial.jl:47</a>
</li>
<li>
    <pre><span class="nf">outdegree</span><span class="p">(</span>
    <span class="n">x</span><span class="p">::</span><span class="n">SparseMatrixCSC{Int64,Ti<:Integer}</span><span class="p">,
</span>    <span class="n">v</span><span class="p">::</span><span class="n">Int64</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/sparsematrix.jl:157</a>
</li>
</ul>

<a id='ParallelGraphs.indegree' href='#ParallelGraphs.indegree'>#</a>
**`ParallelGraphs.indegree`** &mdash; *Function*.



Compute the indegree of a vertex. This method is slow since reverse adjacencies are not stored


Vertex v's indegree in the graph 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre><span class="nf">indegree</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">v</span><span class="p">::</span><span class="n">Int64</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/combinatorial.jl:51</a>
</li>
<li>
    <pre><span class="nf">indegree</span><span class="p">(</span>
    <span class="n">x</span><span class="p">::</span><span class="n">SparseMatrixCSC{Int64,Ti<:Integer}</span><span class="p">,
</span>    <span class="n">v</span><span class="p">::</span><span class="n">Int64</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/sparsematrix.jl:168</a>
</li>
</ul>


<a id='Graph-mutations-1'></a>

### Graph mutations


Graphs can be modified using the following methods:

<a id='ParallelGraphs.addvertex!-Tuple{ParallelGraphs.Graph}' href='#ParallelGraphs.addvertex!-Tuple{ParallelGraphs.Graph}'>#</a>
**`ParallelGraphs.addvertex!`** &mdash; *Method*.



Add a vertex to the graph. Returns the label of the new vertex 

<a id='ParallelGraphs.addvertex!-Tuple{ParallelGraphs.Graph,Any}' href='#ParallelGraphs.addvertex!-Tuple{ParallelGraphs.Graph,Any}'>#</a>
**`ParallelGraphs.addvertex!`** &mdash; *Method*.


<a id='ParallelGraphs.addedge!-Tuple{ParallelGraphs.Graph,Pair{Int64,Int64}}' href='#ParallelGraphs.addedge!-Tuple{ParallelGraphs.Graph,Pair{Int64,Int64}}'>#</a>
**`ParallelGraphs.addedge!`** &mdash; *Method*.



Add an edge to the graph. Returns true if successfull 

<a id='ParallelGraphs.rmvertex!-Tuple{ParallelGraphs.Graph,Int64}' href='#ParallelGraphs.rmvertex!-Tuple{ParallelGraphs.Graph,Int64}'>#</a>
**`ParallelGraphs.rmvertex!`** &mdash; *Method*.



Remove a vertex from the graph 

<a id='ParallelGraphs.rmvertex!-Tuple{ParallelGraphs.Graph,AbstractArray{Int64,1}}' href='#ParallelGraphs.rmvertex!-Tuple{ParallelGraphs.Graph,AbstractArray{Int64,1}}'>#</a>
**`ParallelGraphs.rmvertex!`** &mdash; *Method*.



Remove a list of vertices from the graph 

<a id='ParallelGraphs.rmedge!-Tuple{ParallelGraphs.Graph,Pair{Int64,Int64}}' href='#ParallelGraphs.rmedge!-Tuple{ParallelGraphs.Graph,Pair{Int64,Int64}}'>#</a>
**`ParallelGraphs.rmedge!`** &mdash; *Method*.



Remove an edge from the graph 


<a id='Labelling-1'></a>

### Labelling


New labels can be added or removed through the following methods:

<a id='ParallelGraphs.setlabel!-Tuple{ParallelGraphs.Graph,Array{T,1}}' href='#ParallelGraphs.setlabel!-Tuple{ParallelGraphs.Graph,Array{T,1}}'>#</a>
**`ParallelGraphs.setlabel!`** &mdash; *Method*.



Set labels for all vertices in the graph 

<a id='ParallelGraphs.setlabel!-Tuple{ParallelGraphs.Graph,Symbol}' href='#ParallelGraphs.setlabel!-Tuple{ParallelGraphs.Graph,Symbol}'>#</a>
**`ParallelGraphs.setlabel!`** &mdash; *Method*.



Use a vertex property as the vertex label 

<a id='ParallelGraphs.setlabel!-Tuple{ParallelGraphs.Graph}' href='#ParallelGraphs.setlabel!-Tuple{ParallelGraphs.Graph}'>#</a>
**`ParallelGraphs.setlabel!`** &mdash; *Method*.



Remove all vertex labels 


Labels can be modified through the following methods:

<a id='ParallelGraphs.relabel!-Tuple{ParallelGraphs.Graph,Int64,Any}' href='#ParallelGraphs.relabel!-Tuple{ParallelGraphs.Graph,Int64,Any}'>#</a>
**`ParallelGraphs.relabel!`** &mdash; *Method*.



Relabel a single vertex in the graph 

<a id='ParallelGraphs.relabel!-Tuple{ParallelGraphs.Graph,AbstractArray{Int64,1},Array{T,1}}' href='#ParallelGraphs.relabel!-Tuple{ParallelGraphs.Graph,AbstractArray{Int64,1},Array{T,1}}'>#</a>
**`ParallelGraphs.relabel!`** &mdash; *Method*.



Relabel a list of vertices in the graph 


<!– #################################################################################################################### –>


<a id='EdgeIteration-1'></a>

## EdgeIteration


The EdgeIter type provides alloc-free and fast edge iteration.


<a id='Construction-2'></a>

### Construction

<a id='ParallelGraphs.edges-Tuple{ParallelGraphs.Graph}' href='#ParallelGraphs.edges-Tuple{ParallelGraphs.Graph}'>#</a>
**`ParallelGraphs.edges`** &mdash; *Method*.



Returns an edge iterator containing all edges in the graph 


<a id='Getindex-1'></a>

### Getindex

<a id='Base.getindex-Tuple{ParallelGraphs.EdgeIter,Int64}' href='#Base.getindex-Tuple{ParallelGraphs.EdgeIter,Int64}'>#</a>
**`Base.getindex`** &mdash; *Method*.



Get the ith edge in the iterator 

<a id='Base.getindex-Tuple{ParallelGraphs.EdgeIter,AbstractArray{Int64,1}}' href='#Base.getindex-Tuple{ParallelGraphs.EdgeIter,AbstractArray{Int64,1}}'>#</a>
**`Base.getindex`** &mdash; *Method*.



Get a new iterator containing a subset of the edges 

<a id='Base.getindex-Tuple{ParallelGraphs.EdgeIter,Colon}' href='#Base.getindex-Tuple{ParallelGraphs.EdgeIter,Colon}'>#</a>
**`Base.getindex`** &mdash; *Method*.



Get a copy of the iterator 


<a id='Concatenation-1'></a>

### Concatenation

<a id='Base.vcat-Tuple{ParallelGraphs.EdgeIter,ParallelGraphs.EdgeIter}' href='#Base.vcat-Tuple{ParallelGraphs.EdgeIter,ParallelGraphs.EdgeIter}'>#</a>
**`Base.vcat`** &mdash; *Method*.



Concatenate two iterators 


<a id='Usage-1'></a>

### Usage


```julia
using ParallelGraphs

g = completegraph(3)

# Construct Iterator
eit = edges(g)

# Iterate through edges
for e in eit
   # Do something here
end

# In list comprehensions
[e for e in eit]
```

```
6-element Array{Pair{Int64,Int64},1}:
 1=>2
 1=>3
 2=>1
 2=>3
 3=>1
 3=>2
```


<!– #################################################################################################################### –>


<a id='Metadata-1'></a>

## Metadata


<a id='Setting-vertex-metadata-1'></a>

### Setting vertex metadata

<a id='ParallelGraphs.setvprop!' href='#ParallelGraphs.setvprop!'>#</a>
**`ParallelGraphs.setvprop!`** &mdash; *Function*.



Set vertex properties.

setvprop!(g::Graph, v::VertexID, val(s), vprop::Symbol) -> Set a property for v


setvprop!(g::Graph, vs::VertexList, val(s), vprop::Symbol) -> Set a property for v in vs 


setvprop!(g::Graph, ::Colon, val(s), vprop::Symbol) -> Set a property for all vertices in g 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre><span class="nf">setvprop!</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">v</span><span class="p">::</span><span class="n">Int64</span><span class="p">,
</span>    <span class="n">val</span><span class="p">,
</span>    <span class="n">vprop</span><span class="p">::</span><span class="n">Symbol</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/vdata.jl:57</a>
</li>
<li>
    <pre><span class="nf">setvprop!</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">vs</span><span class="p">::</span><span class="n">AbstractArray{Int64,1}</span><span class="p">,
</span>    <span class="n">val</span><span class="p">,
</span>    <span class="n">vprop</span><span class="p">::</span><span class="n">Symbol</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/vdata.jl:66</a>
</li>
<li>
    <pre><span class="nf">setvprop!</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n"></span><span class="p">::</span><span class="n">Colon</span><span class="p">,
</span>    <span class="n">vals</span><span class="p">::</span><span class="n">AbstractArray{T<:Any,1}</span><span class="p">,
</span>    <span class="n">vprop</span><span class="p">::</span><span class="n">Symbol</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/vdata.jl:76</a>
</li>
<li>
    <pre><span class="nf">setvprop!</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n"></span><span class="p">::</span><span class="n">Colon</span><span class="p">,
</span>    <span class="n">val</span><span class="p">,
</span>    <span class="n">vprop</span><span class="p">::</span><span class="n">Symbol</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/vdata.jl:83</a>
</li>
</ul>


<a id='Retrieving-vertex-metadata-1'></a>

### Retrieving vertex metadata

<a id='ParallelGraphs.getvprop' href='#ParallelGraphs.getvprop'>#</a>
**`ParallelGraphs.getvprop`** &mdash; *Function*.



Retrieve vertex properties.

getvprop(g::Graph, v::VertexID, vprop::Symbol) -> Fetch the value of a property for vertex v


getvprop(g::Graph, vs::VertexList, vprop::Symbol) -> Fetch the value of a property for v in vs 


getvprop(g::Graph, ::Colon, vprop::Symbol) -> Fetch the value of a property for all verices 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre><span class="nf">getvprop</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n"></span><span class="p">::</span><span class="n">Colon</span><span class="p">,
</span>    <span class="n">vprop</span><span class="p">::</span><span class="n">Symbol</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/vdata.jl:47</a>
</li>
<li>
    <pre><span class="nf">getvprop</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">v</span><span class="p">::</span><span class="n">Int64</span><span class="p">,
</span>    <span class="n">vprop</span><span class="p">::</span><span class="n">Symbol</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/vdata.jl:39</a>
</li>
<li>
    <pre><span class="nf">getvprop</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">vs</span><span class="p">::</span><span class="n">AbstractArray{Int64,1}</span><span class="p">,
</span>    <span class="n">vprop</span><span class="p">::</span><span class="n">Symbol</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/vdata.jl:43</a>
</li>
</ul>


<a id='Setting-edge-metadata-1'></a>

### Setting edge metadata

<a id='ParallelGraphs.seteprop!' href='#ParallelGraphs.seteprop!'>#</a>
**`ParallelGraphs.seteprop!`** &mdash; *Function*.



Set edge properties.

seteprop!(g::Graph, e::EdgeID, val, eprop::Symbol) -> Set a property for an edge e


seteprop!(g::Graph, es::EdgeList, val(s), eprop::Symbol) -> Set a property for e in es 


seteprop!(g::Graph, ::Colon, val(s), eprop::Symbol) 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre><span class="nf">seteprop!</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">e</span><span class="p">::</span><span class="n">Pair{Int64,Int64}</span><span class="p">,
</span>    <span class="n">val</span><span class="p">,
</span>    <span class="n">eprop</span><span class="p">::</span><span class="n">Symbol</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/edata.jl:74</a>
</li>
<li>
    <pre><span class="nf">seteprop!</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">es</span><span class="p">::</span><span class="n">AbstractArray{Pair{Int64,Int64},1}</span><span class="p">,
</span>    <span class="n">val</span><span class="p">,
</span>    <span class="n">eprop</span><span class="p">::</span><span class="n">Symbol</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/edata.jl:84</a>
</li>
<li>
    <pre><span class="nf">seteprop!</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n"></span><span class="p">::</span><span class="n">Colon</span><span class="p">,
</span>    <span class="n">vals</span><span class="p">::</span><span class="n">AbstractArray{T<:Any,1}</span><span class="p">,
</span>    <span class="n">eprop</span><span class="p">::</span><span class="n">Symbol</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/edata.jl:94</a>
</li>
<li>
    <pre><span class="nf">seteprop!</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n"></span><span class="p">::</span><span class="n">Colon</span><span class="p">,
</span>    <span class="n">val</span><span class="p">,
</span>    <span class="n">eprop</span><span class="p">::</span><span class="n">Symbol</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/edata.jl:101</a>
</li>
</ul>


<a id='Retrieving-edge-metadata-1'></a>

### Retrieving edge metadata

<a id='ParallelGraphs.geteprop' href='#ParallelGraphs.geteprop'>#</a>
**`ParallelGraphs.geteprop`** &mdash; *Function*.



Retrieve edge properties.

geteprop(g::Graph, e::EdgeID, eprop::Symbol) -> Fetch the value of a property for edge e


geteprop(g::Graph, es::EdgeList, eprop::Symbol) -> Fetch the value of a property for edge e in es 


geteprop(g::Graph, ::Colon, eprop::Symbol) -> Fetch the value of a property for all edges 

<strong>Methods</strong>

<ul class="documenter-methodtable">
<li>
    <pre><span class="nf">geteprop</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n"></span><span class="p">::</span><span class="n">Colon</span><span class="p">,
</span>    <span class="n">eprop</span><span class="p">::</span><span class="n">Symbol</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/edata.jl:63</a>
</li>
<li>
    <pre><span class="nf">geteprop</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">e</span><span class="p">::</span><span class="n">Pair{Int64,Int64}</span><span class="p">,
</span>    <span class="n">eprop</span><span class="p">::</span><span class="n">Symbol</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/edata.jl:55</a>
</li>
<li>
    <pre><span class="nf">geteprop</span><span class="p">(</span>
    <span class="n">g</span><span class="p">::</span><span class="n">ParallelGraphs.Graph</span><span class="p">,
</span>    <span class="n">es</span><span class="p">::</span><span class="n">AbstractArray{Pair{Int64,Int64},1}</span><span class="p">,
</span>    <span class="n">eprop</span><span class="p">::</span><span class="n">Symbol</span>
<span class="p">)</span></pre>
    defined at
    <a target="_blank" href="">src/edata.jl:59</a>
</li>
</ul>


<!– #################################################################################################################### –>


<a id='Queries-1'></a>

## Queries


The query macro is used to execute graph queries in a pipelined manner. The pipelining syntax is borrowed from jplyer, though I hope to use jplyer directly at some point, for lazy execution.


The main functionalities provided by the query macro are:


<a id='eachvertex:-1'></a>

### eachvertex:


This abstraction is used to run an expression on every vertex in the graph, and retrieve a vector result.


For example, `@query g |> eachvertex(v.p1 + v.p2 * v.p3)` executes the expression `v.p1 + v.p2 * v.p3` on every vertex in the result from the previous pipeline stage. Here, `v.p1` denotes the value of property `p1` for every vertex.


<a id='eachedge:-1'></a>

### eachedge:


This abstraction is used to run an expression on every vertex in the graph, and retrieve a vector result.


For example, `@query g |> eachedge(e.p1 + s.p1 + t.p1)` executes the expression `e.p1 + s.p1 + t.p1` on every edge in the graph. Here, 'e.p1' denotes the value of property `p1` for every edge in the graph. Since each edge has a source vertex `s` and a target vertex `t`, the properties of these vertices can be used in the expression as shown by `s.p1` and `t.p1`.


<a id='filter-1'></a>

### filter


This abstraction is used to compute a subgraph of the input from the previous pipeline stage, on the given conditions.


For example, `@query g |> filter(v.p1 < 5, v.p1 < v.p2, e.p1 > 5)` uses the three filter conditions provided to compute a subgraph. Currently only binary comparisons are supported, so comparisons like 1 < v.p1 < v.p2 will not work. Instead you can supply multiple conditions as separate arguments.


<a id='select-1'></a>

### select


This abstraction is used to compute a subgraph of the input from the previous pipeline state, for a subset of vertex and or edge properties.


For example, `@query g |> select(v.p1, v.p3, e.p1)` preserves only vertex properties `p1`,`p2` and edge property `p1`.


<a id='Examples-1'></a>

### Examples


The abstractions can be chained together using the pipe notation, so that the output of one stage becomes the input to the next.


```julia
using ParallelGraphs
g = randgraph(10, [:p1, :p2], [:p1, :p2])

# Run a filter using vertex properties
@query g |> filter(0.5 <= v.p1, v.p1 < v.p2)
```

```
Graph(1 vertices, 0 edges, Symbol[:p1,:p2] vertex properties, Symbol[:p1,:p2] edge properties)
```


```julia
using ParallelGraphs
g = randgraph(10, [:p1, :p2], [:p1, :p2])

# Run a filter using source and target properties
@query g |> filter(s.p1 < t.p2)
```

```
Graph(10 vertices, 26 edges, Symbol[:p1,:p2] vertex properties, Symbol[:p1,:p2] edge properties)
```


```julia
using ParallelGraphs
g = randgraph(10, [:p1, :p2], [:p1, :p2])

# Run filter using edge properties
@query g |> filter(e.p1 < 0.7)
```

```
Graph(10 vertices, 61 edges, Symbol[:p1,:p2] vertex properties, Symbol[:p1,:p2] edge properties)
```


```julia
using ParallelGraphs
g = randgraph(10, [:p1, :p2], [:p1, :p2])

# Chain filter expressions
@query g |> filter(v.p1 < v.p2) |> filter(e.p1 < e.p1)
```

```
Graph(6 vertices, 0 edges, Symbol[:p1,:p2] vertex properties, Symbol[:p1,:p2] edge properties)
```


```julia
using ParallelGraphs
g = randgraph(10, [:p1, :p2], [:p1, :p2])

# Select properties
@query g |> filter(v.p1 < v.p2) |> select(v.p2, e.p1)
```

```
Graph(7 vertices, 42 edges, Symbol[:p2] vertex properties, Symbol[:p1] edge properties)
```


```julia
using ParallelGraphs
g = randgraph(10, [:p1, :p2], [:p1, :p2])

# Run an expression on each vertex
@query g |> eachvertex(v.p1 + v.p2)
```

```
10-element DataArrays.DataArray{Float64,1}:
 0.232198
 0.6771
 0.951151
 0.74152
 1.44636
 0.96192
 0.796451
 0.294686
 1.04942
 1.2093
```


```@example
using ParallelGraphs
g = randgraph(10, [:p1, :p2], [:p1, :p2])

# Run an expression on each edge
@query g |> filter(e.p1 < e.p2) | eachedge(e.p1 + e.p2)
```


The entire query is parsed into a DAG, using a recursive descent parser, and then executed in a bottom up manner. The results of intermediate nodes, and fetched vertex properties are cached to avoid redundant computations.

